# Artifact for the paper "Taming Callbacks for Smart Contract Modularity"

## ECF static checker - Getting Started Guide
This document describes how to run the ECF Checker.
The ECF Checker analyzes EVM bytecode and may accept either raw bytecode or Solidity files.

**The tool is provided as a docker image available from: shellyg/ecf-static-checker:1**

To get the tool, run: `docker pull shellyg/ecf-static-checker:1`

To start the container, run: `docker run -it shellyg/ecf-static-checker:1`.

The container comes packaged with:

- The tool (a JAR file and 3 auxiliary Python scripts). 
- Solidity compiler versions `0.4.25`, `0.5.12`, `0.5.16`, `0.6.12`.
- A set of mini-benchmarks.
- A set of real benchmarks as given in Section 7 of the submission.


### Background information
The artifact implements the ECF static check by implementing the algorithm whose pseudo-code is shown in Figure 6 of the submission.
The actual implementation contains more steps of preprocessing the contract bytecode, some standard static analysis algorithms and optimizations, as described in Section 7 of the submission.

The output produced will say for each function if it is ECF or not.
An additional output JSON file will provide additional information about each callnode analyzed and a list of functions that left-move or right-move with respect to that callnode. (See Definitions 4.10, 4.11.)

#### General run instructions
To run the artifact on a bytecode file `FILE`, run the following command:
```ecf FILE```

To run on a solidity file `FILE.sol` on a contract named `CONTRACT`:
```
ecf FILE.sol "-solc solcX.YY -subContract CONTRACT"
```
where `X.YY` is the required version of the Solidity compiler, either 4.25, 5.12, 5.16, or 6.12. 
If another version is required it can be fetched from the releases page of the Solidity compiler repository: https://github.com/ethereum/solidity/releases.

If the solidity file contains imports, that is, depends on other solidity files, configuring the build might be more complicated.
However sources fetched from https://etherscan.com are flattened and thus the build process should be straight-forward.

A run of `ecf` will generate an `ecf_*.json` file. 
These `json` files were used to collect more detailed statistics about the Top150 benchmark as presented in Appendix B.

### Basic testing

- By running `cd ecf/MiniBenchmarks/DAO/OriginalExample/; ./run.sh` the expected output should be similar to:
```

*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
|Rule name                               |Verified     |Time (sec)|Description                                                 |Local vars                                        |
|----------------------------------------|-------------|----------|------------------------------------------------------------|--------------------------------------------------|
|Bank-deposit()                          |Not violated |..        |                                                            |                                                  |
|Bank-withdraw()                         |Violated     |..        |                                                            |                                                  |
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
```

- By running `cd ~/ecf/MiniBenchmarks/DAO/OriginalExampleFix/; ./run.sh` the expected output is:
```
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
|Rule name                               |Verified     |Time (sec)|Description                                                 |Local vars                                        |
|----------------------------------------|-------------|----------|------------------------------------------------------------|--------------------------------------------------|
|Bank-deposit()                          |Not violated |..        |                                                            |                                                  |
|Bank-withdraw()                         |Not violated |..        |                                                            |                                                  |
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
```

#### Tweaking parameters
Parameters that can be tweaked in the `ecf` script are:  
- `-t` - timeout per SMT query. Default is 600 (seconds).
- `ecfMaxTimePerCallnodeMinutes` - timeout per callnode (see Section 5 for definition of callnode). Default is 30 (minutes).
- `ecfMaxTimePerMultiCallnodeCheckMinutes` - timeout for the multi-callnode phase (see Section 5 in the paper). Default is 30 (minutes).



#### Step-by-step guide

##### Mini benchmarks
The mini benchmarks consist of:
- 8 ECF examples: `exN_ecf` for `N` in 1-8.
  - All of the examples illustrate the concept of the Callback Invariant (Section 6)
- 7 non-ECF examples: `exN_non_ECF` for `N` in 1-7.
- 3 pairs (total: 6) of examples based on the DAO hack, where each is illustrating a different fix.
  - `DAO/OriginalExample` and `DAO/OriginalExampleFix` - the example from Figure 2 and the line-reordering fix.
  - `DAO/OriginalExampleBasicLock` and `DAO/OriginalExampleBasicLockBroken` - the fix based on Figure 5 and a mutation that breaks the fix and makes it non-ECF.
  - `DAO/OriginalExampleMonotoneLock` and `DAO/OriginalExampleMonotoneLockBroken` - a fix based on increasing counter lock and a mutation that break the fix and makes it non-ECF. 
     The corrected code can be proven using a callback invariant as shown in Section 6. Note, however, that the implementation given in this artifact cannot express the callback invariant that proves the fix correct, since it cannot refer to local variables of a method.
- An example illustrating the special revert handling described in Appendix A: `DAO/OriginalExampleJustifyRevertsInSuffix`. In this example, `withdraw_with_inv_assumed` is ECF, but `withdraw` cannot be proven ECF without applying the technique described in Appendix A. 
The output of the tool shows that the right movement check succeeds, since it implements the technique in Appendix A.

Each one of the subdirectories in `~/ecf/MiniBenchmarks` contains a runner script `run.sh` to run the example with the tool, and an `expected.json` file that can be used to compare the actual results to expected results.

##### Top150 benchmark
To run on any individual contract from the Top150 benchmark, run:
```
ecf ecf/Top150Benchmarks/XXX.bin-runtime
```
Where `XXX` is a string that represents the address of the contract.
Note that running on all 150 contracts takes a long time.

If available, it is possible to run on the Solidity file matching a bytecode file. The output is then human readable.
To do so, run:
```
ecf ecf/Top150Benchmarks/XXX.sol "-solc solcX.YY -subContract NAME_OF_CONTRACT_IN_XXX "
```
where `NAME_OF_CONTRACT_IN_XXX` should be a contract declared in `XXX.sol` and `solcX.YY` should match the declared pragma version in `XXX.sol`.

For example, we can run on the contract with address 0xb363a3c584b1f379c79fbf09df015da5529d4dac either directly on the bytecode or with Solidity sources.
If we run with the bytecode only like this: `ecf ~/ecf/Top150Benchmarks/0xb363a3c584b1f379c79fbf09df015da5529d4dac.bin-runtime`
we get the output:
```
Results for 0xb363a3c584b1f379c79fbf09df015da5529d4dac:
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-95ea7b3(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-21670f22(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-23b872dd(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-645ac00b(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-751c4d70(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-a0712d68(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-a4e3374b(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-a9059cbb(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-f2fde38b(): V
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-90cebff(): X
    Result for 0xb363a3c584b1f379c79fbf09df015da5529d4dac-3f55b895(): X
```
Indicating that the methods identified by the 4-byte sighashes (See explanation at https://www.4byte.directory/) 0x90cebff and 0x3f55b895 may be vulnerable to reentrancy attacks.

But if we run with the sources like this: `ecf ~/ecf/Top150Benchmarks/0xb363a3c584b1f379c79fbf09df015da5529d4dac.sol "-solc solc4.25 -subContract MiracleTeleToken"`
we get the output:
```
Results for MiracleTeleToken:
    Result for MiracleTeleToken-approve(address,uint256): V
    Result for MiracleTeleToken-reward(address,uint256): V
    Result for MiracleTeleToken-transferFrom(address,address,uint256): V
    Result for MiracleTeleToken-transferSignership(address): V
    Result for MiracleTeleToken-contributeDelegated(address,uint256): V
    Result for MiracleTeleToken-mint(uint256): V
    Result for MiracleTeleToken-transferDelegated(address,address,uint256): V
    Result for MiracleTeleToken-transfer(address,uint256): V
    Result for MiracleTeleToken-transferOwnership(address): V
    Result for MiracleTeleToken-unDelegate(uint8,bytes32,bytes32): X
    Result for MiracleTeleToken-delegate(uint8,bytes32,bytes32): X
```
Here it becomes clear that the two suspected non-ECF functions are `unDelegate` and `delegate`. (These methods would be vulnerable if precompiled contracts allowed reentrancy, which is not the case.)

### Running the comparative benchmarks
Simple installation instructions using docker are provided below.
The instructions assume the artifact's git repository is locally cloned into `ECF_DIR` (full path should be given as argument to docker).

#### _Slither_
_Slither_ can only be run on contracts with source whose supported compiler version is packaged with _Slither_'s docker container.

To get Slither, run:
```
docker pull trailofbits/eth-security-toolbox
```

To run _Slither_, first run the docker:  
```
docker run -it -v ECF_DIR:/share trailofbits/eth-security-toolbox
```
and in the container, run:
```
sudo chmod -R 755 /share
```

Within the docker:
- _Slither_ can be run on on individual contracts with:
```
solc-select 0.X.YY
slither FILE.SOL --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json out.json
```
with `X.YY` standing for the Solidity version.

- To run _Slither_ on the contracts in the mini benchmark set, run:
```
/share/runSlitherMini.sh
```

- To run _Slither_ on all compatible contracts in the Top150 benchmark, run the script:
```
/share/runSlitherTop150.sh
```



#### _Securify2_
Securify2 only supports contracts compiled with Solidity versions 0.5.8 and above.

To install Securify2, run:
```
git clone https://github.com/eth-sri/securify2.git
cd securify2
sudo docker build -t securify .
```

- To run _Securify2_ on individual contracts:  
```
sudo docker run -it -v ECF_DIR:/share securify /share/CONTRACT_FILE.sol
```
where `CONTRACT_FILE.sol` is the the solidity file describing the contract.

- To run _Securify2_ on all of the mini benchmarks:  
```
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex1_ecf/ex1_ECF.sol >& securify.1ecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex2_ecf/ex2_ECF.sol >& securify.2ecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex3_ecf/ex3_ECF.sol >& securify.3ecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex4_ecf/ex4_ECF.sol >& securify.4ecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex5_ecf/ex5_ECF.sol >& securify.5ecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex6_ecf/ex6_ECF.sol >& securify.6ecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex7_ecf/ex7_ECF.sol >& securify.7ecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex8_ecf/ex8_ECF.sol >& securify.8ecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex1_non_ecf/ex1_nonECF.sol >& securify.1nonecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex2_non_ecf/ex2_nonECF.sol >& securify.2nonecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex3_non_ecf/ex3_nonECF.sol >& securify.3nonecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex4_non_ecf/ex4_nonECF.sol >& securify.4nonecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex5_non_ecf/ex5_nonECF.sol >& securify.5nonecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex6_non_ecf/ex6_nonECF.sol >& securify.6nonecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks:/share securify /share/ex7_non_ecf/ex7_nonECF.sol >& securify.7nonecf.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks/DAO:/share securify /share/OriginalExample/OriginalExample.sol >& securify.original.example.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks/DAO:/share securify /share/OriginalExampleFix/OriginalExampleFix.sol >& securify.original.example.fix.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks/DAO:/share securify /share/OriginalExampleBasicLock/OriginalExampleBasicLock.sol >& securify.original.example.basic.lock.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks/DAO:/share securify /share/OriginalExampleBasicLockBroken/OriginalExampleBasicLockBroken.sol >& securify.original.example.basic.lock.broken.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks/DAO:/share securify /share/OriginalExampleMonotoneLock/OriginalExampleMonotoneLock.sol >& securify.original.example.monotone.lock.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks/DAO:/share securify /share/OriginalExampleMonotoneLockBroken/OriginalExampleMonotoneLockBroken.sol >& securify.original.example.monotone.lock.broken.txt
sudo docker run -it -v ECF_DIR/MiniBenchmarks/DAO:/share securify /share/OriginalExampleJustifyRevertsInSuffix/OriginalExampleJustifyRevertsInSuffix.sol >& securify.original.example.justify.reverts.in.suffix.txt
```

- To run _Securify2_ on the subset of compatible contracts out of the Top150 benchmark:
```
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0x174bfa6600bf90c885c7c01c7031389ed1461ab9.sol >& securify.0x174bfa6600bf90c885c7c01c7031389ed1461ab9.txt 
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0x5e07b6f1b98a11f7e04e7ffa8707b63f1c177753.sol >& securify.0x5e07b6f1b98a11f7e04e7ffa8707b63f1c177753.txt 
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0xbf5f8bfcee9502a30018d91c63eca66980e6e9bb.sol >& securify.0xbf5f8bfcee9502a30018d91c63eca66980e6e9bb.txt  
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0xd7cc16500d0b0ac3d0ba156a584865a43b0b0050.sol >& securify.0xd7cc16500d0b0ac3d0ba156a584865a43b0b0050.txt
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0x2e65e12b5f0fd1d58738c6f38da7d57f5f183d1c.sol >& securify.0x2e65e12b5f0fd1d58738c6f38da7d57f5f183d1c.txt  
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0x931abd3732f7eada74190c8f89b46f8ba7103d54.sol >& securify.0x931abd3732f7eada74190c8f89b46f8ba7103d54.txt  
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0xcafe27178308351a12fffffdeb161d9d730da082.sol >& securify.0xcafe27178308351a12fffffdeb161d9d730da082.txt
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0x5b8174e20996ec743f01d3b55a35dd376429c596.sol >& securify.0x5b8174e20996ec743f01d3b55a35dd376429c596.txt  
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0x999999c60566e0a78df17f71886333e1dace0bae.sol >& securify.0x999999c60566e0a78df17f71886333e1dace0bae.txt 
sudo docker run -it -v ECF_DIR/Top150Benchmarks:/share securify /share/0xd5dc8921a5c58fb0eba6db6b40eab40283dc3c01.sol >& securify.0xd5dc8921a5c58fb0eba6db6b40eab40283dc3c01.txt
```
