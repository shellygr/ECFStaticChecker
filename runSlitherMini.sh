set -x
solc-select 0.5.12
slither /share/MiniBenchmarks/DAO/OriginalExample/OriginalExample.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json OriginalExample.out.json
slither /share/MiniBenchmarks/DAO/OriginalExampleFix/OriginalExampleFix.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json OriginalExample.out.json
slither /share/MiniBenchmarks/DAO/OriginalExampleBasicLock/OriginalExampleBasicLock.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json OriginalExampleBasicLock.out.json
slither /share/MiniBenchmarks/DAO/OriginalExampleBasicLockBroken/OriginalExampleBasicLockBroken.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json OriginalExampleBasicLockBroken.out.json
slither /share/MiniBenchmarks/DAO/OriginalExampleMonotoneLock/OriginalExampleMonotoneLock.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json OriginalExampleMonotoneLock.out.json
slither /share/MiniBenchmarks/DAO/OriginalExampleMonotoneLockBroken/OriginalExampleMonotoneLockBroken.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json OriginalExampleMonotoneLockBroken.out.json
slither /share/MiniBenchmarks/DAO/OriginalExampleJustifyRevertsInSuffix/OriginalExampleJustifyRevertsInSuffix.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json OriginalExampleJustifyRevertsInSuffix.out.json
slither /share/MiniBenchmarks/ex1_ecf/ex1_ECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex1_ecf.out.json
slither /share/MiniBenchmarks/ex2_ecf/ex2_ECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex2_ecf.out.json
slither /share/MiniBenchmarks/ex3_ecf/ex3_ECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex3_ecf.out.json
slither /share/MiniBenchmarks/ex4_ecf/ex4_ECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex4_ecf.out.json
slither /share/MiniBenchmarks/ex5_ecf/ex5_ECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex5_ecf.out.json
slither /share/MiniBenchmarks/ex6_ecf/ex6_ECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex6_ecf.out.json
slither /share/MiniBenchmarks/ex7_ecf/ex7_ECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex7_ecf.out.json
slither /share/MiniBenchmarks/ex8_ecf/ex8_ECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex8_ecf.out.json
slither /share/MiniBenchmarks/ex1_non_ecf/ex1_nonECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex1_non_ecf.out.json
slither /share/MiniBenchmarks/ex2_non_ecf/ex2_nonECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex2_non_ecf.out.json
slither /share/MiniBenchmarks/ex3_non_ecf/ex3_nonECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex3_non_ecf.out.json
slither /share/MiniBenchmarks/ex4_non_ecf/ex4_nonECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex4_non_ecf.out.json
slither /share/MiniBenchmarks/ex5_non_ecf/ex5_nonECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex5_non_ecf.out.json
slither /share/MiniBenchmarks/ex6_non_ecf/ex6_nonECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ex6_non_ecf.out.json
slither /share/MiniBenchmarks/ex7_non_ecf/ex7_nonECF.sol --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign,reentrancy-unlimited-gas  --json ה.out.jsonד