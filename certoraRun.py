#!/usr/bin/env python3

import os
import sys
import subprocess
import traceback
import certoraUtils
from certoraUtils import read_from_conf, get_certora_root_directory
from certoraUtils import OPTION_CACHE, DEFAULT_CONF
from certoraUtils import nestedOptionHack, debug_print
from certoraUtils import sanitize_path, prepare_call_args
from certoraUtils import legal_run_args, check_legal_args

from typing import Dict, List, Optional, Tuple, Any

# a list of valid environments to be used when running remotly
VALID_ENVS = ["staging"]
JAR_PATH_KEY = "jar_path"
BUILD_SCRIPT_PATH_KEY = "build_script_path"

def print_usage() -> None:
    print("""Usage:
       If no arguments, read from default.conf
       Otherwise:
       [file[:contractName] ...] or CONF_FILE.conf
       [--settings [flag1,...,k1=v1,...]]
       [--cache NAME]
       [--output OUTPUT_FILE_NAME (default: .certora_build)]
       [--output_folder OUTPUT_FOLDER_NAME (default: .certora_config)]
       [--link [contractName:slot=contractName ...]]
       [--address [contractName:address ...] (default: auto-assigned)]
       [--path ALLOWED_PATH (default: $PWD/contracts/)]
       [--packages_path PATH (default: $NODE_PATH)] or [--packages [name=path,...]]
       [--solc SOLC_EXEC (default: solc)] or [--solc_map [name=solc,..]]
       [--solc_args 'SOLC_ARGS' (default: none. wrap in quotes, may need to escape)]
       [--verify [contractName:specName ...] (space separated)]
       [--assert [contractName, ...]]
       [--dont_fetch_sources]
       [--iscygwin]
       [--varmap]
       [--build PATH_TO_BUILD_SCRIPT (default: $CERTORA/certoraBuild.py)]
       [--jar JAR_FULL_PATH (only in local mode - full path to jar including name)]
       [--debug]
       [--help]
       [--remote [environment] (run on the amazon server, default environment is production)]""",
          flush=True)

def run_cmd(cmd: str) -> None:
    try:
        args = prepare_call_args(cmd)
        exitcode = subprocess.call(args, shell=False)
        if exitcode:
            debug_print(str(args))
            print("Failed to run %s, exitcode %d" % (' '.join(args), exitcode), flush=True)
            debug_print("Path is %s" % (os.getenv("PATH"),))
            sys.exit(1)
        else:
            debug_print("Exitcode %d" % (exitcode,))
    except Exception:
        debug_print(str(args))
        print("Failed to run %s" % (cmd,), flush=True)
        debug_print(str(sys.exc_info()))
        sys.exit(1)

def getRemoteFlag(script_args: Dict[str, str]) -> str:
    remote_flag = script_args["remote_flag"]
    if remote_flag == "" or remote_flag is None:
        return ""
    elif remote_flag in VALID_ENVS:
        return "--" + remote_flag
    else:
        print("%s is not one of the available environment: %s" % (remote_flag, VALID_ENVS))
        sys.exit(1)

"""
    This code parses a settings arg string.
    Commas ',' separate different settings.
    Since commas can appear inside values (like for method choice, '-m'),
    we need to ignore commas that appear within parenthesis.
    It's not a regular property, so we just parse this string.
    This is done by iterating over the characters and maintaining whether we're
    reading the key (assumed that it can't have commas) (IS_KEY),
            the value (which may have commas only within parenthesis) (not IS_KEY),
            in-between (comma for key only, or '=' for key-value properties),
            where we are in the portion (key/value) (idxPortion),
            the current key (KEY) or value (VALUE),
            where we are in the string (idxString),
            how many parenthesis we didn't close yet (COUNT_PAREN)
"""
def parse_settings_arg(settingsArg: str) -> List[str]:
    debug_print("Parsing {}".format(settingsArg))
    COUNT_PAREN = 0
    IS_KEY = True
    idxString = 0
    idxPortion = 0
    KEY = ""
    VALUE = ""
    args_list = []
    while idxString < len(settingsArg):
        ch = settingsArg[idxString]
        # debug_print("handling char {}".format(ch))
        if IS_KEY:
            if ch == '(' or ch == ')':
                print("""Error: Cannot contain parenthesis in key,
                got {} in index {} of {}""".format(ch, idxString, settingsArg))
                sys.exit(1)

            if idxPortion == 0:
                if ch != '-':
                    print("Error: parsing settings {}, expected '-', got {}".format(settingsArg, ch))
                    sys.exit(1)
                KEY = "-"
                idxPortion += 1
                idxString += 1
                continue

            if idxPortion > 0:
                if ch == '=':
                    debug_print("Got key {}".format(KEY))
                    IS_KEY = False
                    idxPortion = 0
                    idxString += 1
                elif ch == ',':
                    KEY += " "
                    # Still key, but no value
                    debug_print("Adding {}".format(KEY))
                    args_list.append(KEY)
                    KEY = ""
                    idxPortion = 0
                    idxString += 1
                else:
                    KEY += ch
                    if idxString + 1 == len(settingsArg):  # finishing
                        debug_print("Adding {}".format(KEY))
                        args_list.append(KEY)
                    idxPortion += 1
                    idxString += 1
            continue

        # Here: is handling VALUE
        if not IS_KEY:
            if ch == '(':
                COUNT_PAREN += 1
            if ch == ')':
                COUNT_PAREN -= 1

            if COUNT_PAREN < 0:
                print("Error: Unbalanced parenthesis in {}".format(settingsArg))
                sys.exit(1)

            if (ch == "," and COUNT_PAREN == 0) or idxString + 1 == len(settingsArg):
                # done with this pair
                if ch != ",":
                    VALUE += ch  # close parenthesis probably

                if COUNT_PAREN > 0:
                    print("Error: Cannot close value {} if parenthesis are unbalanced".format(VALUE))
                    sys.exit(1)

                debug_print("Adding {} {}".format(KEY, VALUE))
                args_list.append("{} {}".format(KEY, VALUE))
                IS_KEY = True
                KEY = ""
                VALUE = ""
                idxPortion = 0
                idxString += 1
            else:
                VALUE += ch
                idxString += 1
                idxPortion += 1

    return args_list

def parse_args(args: List[str]) -> Tuple[List[str], Dict[str, Any], List[str]]:
    build_args, run_args = [], []
    script_args = {}  # type: Dict[str, Any]

    i = 0
    is_remote = False
    is_jar = False
    while i < len(args):
        current_arg = args[i]
        current_potential_value = args[i + 1] if len(args) > i + 1 else None
        if current_arg == "--remote":
            if current_potential_value is not None and not current_potential_value.startswith("-"):
                i += 1
                script_args["remote_flag"] = current_potential_value
            else:
                # when it's production, --remote should have no args
                script_args["remote_flag"] = ""
            is_remote = True

        elif current_arg == "--settings":
            i += 1  # inc for the settings
            if current_potential_value is not None:
                run_args.extend(parse_settings_arg(current_potential_value))
            else:
                print("--settings requires an argument", flush=True)
                sys.exit(1)
        elif current_arg == "--jar":
            is_jar = True
            i += 1  # inc for the path
            script_args[JAR_PATH_KEY] = current_potential_value
        elif current_arg == "--build":
            i += 1  # inc for the path
            script_args[BUILD_SCRIPT_PATH_KEY] = current_potential_value
        else:
            build_args.append(current_arg)

        i += 1

    if len(build_args) == 0 or (build_args[0].endswith(".conf") or build_args[0].startswith("--")):
        # No build args (default.conf) or first build arg ends with .conf or starts with -- (an option)
        files = []  # type: List[str]
        fileToContractName = {}  # type: Dict[str, str]
        parsed_options = {"solc": "solc"}
        if len(build_args) == 0:
            conf_file = DEFAULT_CONF
        else:
            conf_file = build_args[0]

        read_from_conf(conf_file, parsed_options, files, fileToContractName)

        if OPTION_CACHE in parsed_options:
            build_args.append("--cache")
            build_args.append(parsed_options[OPTION_CACHE])

    if is_remote and is_jar:
        print("--jar not supported in remote mode", flush=True)
        sys.exit(1)

    return build_args, script_args, run_args

def get_cache_key(args: List[str]) -> Optional[str]:
    if "--cache" in args:
        location_of_cache = args.index("--cache")
        if location_of_cache + 1 >= len(args):
            print("Did not provide cache key", flush=True)
            sys.exit(1)
        else:
            return args[location_of_cache + 1]
    else:
        return None

def get_cache_param(cache_arg: Optional[str]) -> str:
    if cache_arg is not None:
        return " -cache %s" % (cache_arg)
    else:
        return ""

try:
    # Remove the python file
    args = sys.argv[1:]

    if "--debug" in sys.argv:
        certoraUtils.DEBUG = True

    nestedOptionHack(args)

    if "--help" in args:
        print_usage()
        sys.exit(1)

    check_legal_args(args, legal_run_args)
    build_args, script_args, run_args = parse_args(args)

    if BUILD_SCRIPT_PATH_KEY in script_args:
        build_script_path = sanitize_path(script_args[BUILD_SCRIPT_PATH_KEY])
    else:
        build_script_path = "certoraBuild.py"

    if len(build_args) > 0:
        build_cmd = "%s %s" % (build_script_path, ' '.join(build_args))
    else:
        build_cmd = build_script_path

    cache_arg = get_cache_key(build_args)
    if cache_arg is not None:
        run_args.append(get_cache_param(cache_arg))
    if "remote_flag" in script_args:
        if len(run_args) > 0:
            print("cannot support additional settings with running remotely")
            sys.exit(1)
        check_cmd = " ".join(["java", "-jar", "%s/prover_cli.jar" %
                              (sanitize_path(get_certora_root_directory()),), "%s" % getRemoteFlag(script_args),
                              "verify", "."])
    else:
        if JAR_PATH_KEY not in script_args:
            jar_path = "%s/emv.jar" % (sanitize_path(get_certora_root_directory()),)
        else:
            jar_path = script_args[JAR_PATH_KEY]
        check_cmd = " ".join(["java", "-jar", jar_path] + run_args)
    debug_print("Running the verifier like this:\n %s" % (check_cmd,))

    print("Building: %s" % (build_cmd,), flush=True)
    run_cmd(build_cmd)
    print("Running: %s" % (check_cmd,), flush=True)
    run_cmd(check_cmd)

except Exception:
    print("Encountered an error running Certora ASA:", flush=True)
    print(traceback.format_exc(), flush=True)
    print_usage()
except KeyboardInterrupt:
    print('Interrupted', flush=True)
