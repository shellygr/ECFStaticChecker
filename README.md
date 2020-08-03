# Artifact for the paper "Taming Callbacks for Smart Contract Modularity"

## ECF Static checker
This document describes how to run the ECF Checker installed in the VM provided.
The ECF Checker analyzes EVM bytecode and may accept either raw bytecode or Solidity files.

### VM Contents

Credentials:
- username: **ecf**
- password: **oopsla**


The VM comes packaged with:

- The tool. 
- Solidity compiler versions 0.4.25, 0.5.16, 0.6.12.
- A set of mini-benchmarks.
- A set of real benchmarks as given in Section 7 of the submission.
- Installations of competing tools _Securify2_ and _Slither_ (via docker).


**Install the artifact from https://www.cs.tau.ac.il/~shellygr/vms/ECFStaticChecker.ova**

### Background information
The artifact implements the ECF static check by implementing the algorithm whose pseudo-code is shown in Figure 6 of the submission.
The actual implementation contains more steps of preprocessing the contract bytecode, some standard static analysis algorithms and optimizations, as described in Section 7 of the submission.

The output produced will say for each function if it is ECF or not.
An additional output JSON file will provide additional information about each callnode analyzed and a list of functions that left-move or right-move with respect to that callnode. (See Definitions 4.10, 4.11.)

#### General run instructions
To run the artifact on a bytecode file `FILE`, run the following command:
```ecf FILE```
To run on a solidity file `FILE.sol`:
```ecf FILE.sol "-solc solcX.YY"```
where `X.YY` is the required version of the Solidity compiler, either 4.25, 5.16, or 6.12. 
If another version is required it can be fetched from the releases page of the Solidity compiler repository: https://github.com/ethereum/solidity/releases.

#### Tweaking parameters
Parameters that can be tweaked in the `ecf` script are:  
- `-t` - timeout per SMT query. Default is 600 seconds.
- `ecfMaxTimePerCallnodeMinutes` - timeout per callnode (see Section 5 for definition of callnode). Default is 30 minutes.
- `ecfMaxTimePerMultiCallnodeCheckMinutes` - timeout for the multi-callnode phase (see Section 5 in the paper). Default is 30 minutes.



#### Step-by-step guide

##### Mini benchmarks
The mini benchmarks consist of:
- 8 ECF examples: `exN_ecf` for `N` in 1-8.
- 7 non-ECF examples: `exN_non_ECF` for `N` in 1-7.
- 3 pairs (total: 6) of examples based on the DAO hack, where each is illustrating a different fix.
  - `DAO/OriginalExample` and `DAO/OriginalExampleFix` - the example from Figure 2 and the line-reordering fix.
  - `DAO/OriginalExampleBasicLock` and `DAO/OriginalExampleBasicLockBroken` - the fix based on Figure 5 and a mutation that breaks the fix and makes it non-ECF.
  - `DAO/OriginalExampleMonotoneLock` and `DAO/OriginalExampleMonotoneLockBroken` - a fix based on increasing counter lock and a mutation that break the fix and makes it non-ECF. 
- An example illustrating the special revert handling described in Appendix A: `TODO`
TODO: Rewrite run.sh scripts in all subfolders and double check the expected.json

##### Top150 benchmark
TODO: Prepare the run script based on clara5
To run on any individual contract from the Top150 benchmark, run:
```
```
Running on all 150 contracts takes a long time.


### Running the comparative benchmarks

#### _Slither_
_Slither_ can only be run on contracts with source whose supported compiler version is packaged with _Slither_'s docker container.
To run _Slither_, first run the docker:  
```
docker run -it -v ~/ecf:/share trailofbits/eth-security-toolbox
```
and in the container, run:  [TODO Optional?]
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
```

- To run _Slither_ on all compatible contracts in the Top150 benchamrk, run the script:
```
/share/runWithSourceSlither.sh
```



#### _Securify2_
Securify2 only supports contracts compiled with Solidity versions 0.5.8 and above.
- To run _Securify2_ on individual contracts, use:  
```
sudo docker run -it -v PATH_TO_CONTRACTS:/share securify /share/CONTRACT_FILE.sol
```

- To run _Securify2_ on all of the mini benchmarks, use:  
```
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex1_ecf/ex1_ECF.sol >& securify.1ecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex2_ecf/ex2_ECF.sol >& securify.2ecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex3_ecf/ex3_ECF.sol >& securify.3ecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex4_ecf/ex4_ECF.sol >& securify.4ecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex5_ecf/ex5_ECF.sol >& securify.5ecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex6_ecf/ex6_ECF.sol >& securify.6ecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex7_ecf/ex7_ECF.sol >& securify.7ecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex8_ecf/ex8_ECF.sol >& securify.8ecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex1_non_ecf/ex1_nonECF.sol >& securify.1nonecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex2_non_ecf/ex2_nonECF.sol >& securify.2nonecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex3_non_ecf/ex3_nonECF.sol >& securify.3nonecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex4_non_ecf/ex4_nonECF.sol >& securify.4nonecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex5_non_ecf/ex5_nonECF.sol >& securify.5nonecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex6_non_ecf/ex6_nonECF.sol >& securify.6nonecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks:/share securify /share/ex7_non_ecf/ex7_nonECF.sol >& securify.7nonecf.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks/DAO:/share securify /share/OriginalExample/OriginalExample.sol >& securify.original.example.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks/DAO:/share securify /share/OriginalExampleFix/OriginalExampleFix.sol >& securify.original.example.fix.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks/DAO:/share securify /share/OriginalExampleBasicLock/OriginalExampleBasicLock.sol >& securify.original.example.basic.lock.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks/DAO:/share securify /share/OriginalExampleBasicLockBroken/OriginalExampleBasicLockBroken.sol >& securify.original.example.basic.lock.broken.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks/DAO:/share securify /share/OriginalExampleMonotoneLock/OriginalExampleMonotoneLock.sol >& securify.original.example.monotone.lock.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks/DAO:/share securify /share/OriginalExampleMonotoneLockBroken/OriginalExampleMonotoneLockBroken.sol >& securify.original.example.monotone.lock.broken.txt
sudo docker run -it -v ~/ecf/MiniBenchmarks/DAO:/share securify /share/OriginalExampleJustifyRevertsInSuffix/OriginalExampleJustifyRevertsInSuffix.sol >& securify.original.example.justify.reverts.in.suffix.txt
```

- To run _Securify2_ on the subset of compatible contracts out of the Top150 benchmark, run:
```
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0x174bfa6600bf90c885c7c01c7031389ed1461ab9.sol >& securify.0x174bfa6600bf90c885c7c01c7031389ed1461ab9.txt 
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0x5e07b6f1b98a11f7e04e7ffa8707b63f1c177753.sol >& securify.0x5e07b6f1b98a11f7e04e7ffa8707b63f1c177753.txt 
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0xbf5f8bfcee9502a30018d91c63eca66980e6e9bb.sol >& securify.0xbf5f8bfcee9502a30018d91c63eca66980e6e9bb.txt  
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0xd7cc16500d0b0ac3d0ba156a584865a43b0b0050.sol >& securify.0xd7cc16500d0b0ac3d0ba156a584865a43b0b0050.txt
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0x2e65e12b5f0fd1d58738c6f38da7d57f5f183d1c.sol >& securify.0x2e65e12b5f0fd1d58738c6f38da7d57f5f183d1c.txt  
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0x931abd3732f7eada74190c8f89b46f8ba7103d54.sol >& securify.0x931abd3732f7eada74190c8f89b46f8ba7103d54.txt  
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0xcafe27178308351a12fffffdeb161d9d730da082.sol >& securify.0xcafe27178308351a12fffffdeb161d9d730da082.txt
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0x5b8174e20996ec743f01d3b55a35dd376429c596.sol >& securify.0x5b8174e20996ec743f01d3b55a35dd376429c596.txt  
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0x999999c60566e0a78df17f71886333e1dace0bae.sol >& securify.0x999999c60566e0a78df17f71886333e1dace0bae.txt 
sudo docker run -it -v ~/ecf/Top150Benchmarks:/share securify /share/0xd5dc8921a5c58fb0eba6db6b40eab40283dc3c01.sol >& securify.0xd5dc8921a5c58fb0eba6db6b40eab40283dc3c01.txt
```