** tools
1. https://github.com/t4sk/hello-smart-contract-security-tools#slither
2. https://github.com/crytic/slither
3. https://github.com/trailofbits/eth-security-toolbox


** references:
1. https://www.youtube.com/watch?v=Dxex3b-eMq0


** questions
1. slither import errors
https://github.com/crytic/slither/issues/1121
slither Contract.sol --solc-remaps "$(tr '\n' ' ' < ../../remappings.txt | xargs)" 
2. As ERC1363BondingCurveToken use the BancorFormula, which leads to many dedectors while do the slither check


** Test command

slither src/SmartContractTrio --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)" --compile-force-framework foundry

1. slither src --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)" --exclude-dependencies &>coreFunctionsExcludeDependencies.md
2. slither src/ERC1363BondingCurveToken.sol --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)"
3. slither src/SanctionToken.sol --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)"
4. slither src --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)" --print human-summary
6. slither src --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)" --print contract-summary
7. slither src --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)" --print call-graph
8. slither src --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)" --print cfg (each function)
9. slither src --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)" --print function-summary
10.slither src --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)" --print vars-and-auth

11. slither-check-erc src/SanctionToken.sol SanctionToken --solc-remaps "$(tr '\n' ' ' < remappings.txt | xargs)"


mythx tools.

mythx --api-key xxxx. analyze --async src/NFTEnumerableContracts/ src/SmartContractTrio/ --remap-import "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/"

** other related references
1. https://github.com/crytic/slither/blob/master/trophies.md
2. https://github.com/crytic/slither/wiki/Printer-documentation other-printer

TOOD
slither . --print inheritance-graph xdot contracts.dot


** should check todo
1. Reentrancy problems
2. 


questions: todo

1) while project includes foundry and hardhart, how to only specify foundry and apply slither corrrectly.

