import fs from "fs";
import csv from 'csv-parser';
import { ethers } from "ethers";
import { MerkleTree } from 'merkletreejs';
import keccak256 from "keccak256";

const csvFile = 'csv/users.csv';
const outputPath = 'json/merkle-data.json';

interface MerkleData {
    root: string;
    claims: {
        [address: string]: {
            amount: string;
            proof: string[];
        };
    };
}

let res: Buffer[] = [];
let addresses: string[] = [];
let amounts: string[] = [];

fs.createReadStream(csvFile)
    .pipe(csv())
    .on("data", (row: { address: string; amount: number }) => {
        const address = row.address;
        const amount = ethers.utils.parseUnits(row.amount.toString(), 18);

        addresses.push(address);
        amounts.push(amount.toString());
        const leaf = keccak256(
            ethers.utils.solidityPack(["address", "uint256"], [address, amount])
        );
        res.push(leaf);
    })
        

    .on("end", () => {
        const merkleTree = new MerkleTree(res, keccak256, {
            sortPairs: true,
        });

        const rootHash = merkleTree.getHexRoot();
        
        // Create claims object
        const claims: MerkleData['claims'] = {};
        
        addresses.forEach((address, index) => {
            const leaf = keccak256(
                ethers.utils.solidityPack(["address", "uint256"], [address, amounts[index]])
            );
            
            claims[address] = {
                amount: amounts[index],
                proof: merkleTree.getHexProof(leaf)
            };
        });

        const merkleData: MerkleData = {
            root: rootHash,
            claims
        };

        // Write to JSON file
        fs.writeFileSync(
            outputPath,
            JSON.stringify(merkleData, null, 2)
        );

        console.log("Merkle data written to:", outputPath);
        console.log("Root:", rootHash);
    });