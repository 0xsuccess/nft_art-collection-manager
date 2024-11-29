# NFT Collection Manager Smart Contract

## Overview

This **NFT Collection Manager** smart contract is designed to manage a collection of digital art NFTs. It provides functionality to:
- **Create, update, transfer, and delete** art pieces.
- Manage **ownership** and **access control** for each NFT.
- Store and validate metadata such as **title**, **creator**, **size**, **description**, and **tags**.

Built with **Clarity 2.0**, this contract ensures that only authorized users can modify or transfer ownership of NFTs, while maintaining efficient storage and access validation.

---

## Features

### Key Functionalities
- **NFT Creation**: Add a new digital art NFT to the collection.
- **Ownership Transfer**: Change ownership of an NFT to another user.
- **Metadata Management**: Update title, size, description, and tags for an NFT.
- **Access Control**: Restrict access to authorized users.
- **Deletion**: Remove an NFT from the collection.

### Key Attributes
Each NFT is uniquely identified by an `art-id` and includes:
- **Title**: Name of the art piece (ASCII, max 64 characters).
- **Creator**: The principal address of the creator.
- **Size**: Numeric size of the art piece.
- **Description**: Short description of the art (ASCII, max 128 characters).
- **Tags**: A list of descriptive tags (up to 10 tags, each max 32 characters).

---

## Error Codes

| Error Code           | Description                                    |
|-----------------------|------------------------------------------------|
| `ERR-ART-NOT-FOUND`   | Art piece not found.                          |
| `ERR-DUPLICATE-ART`   | Attempt to add an existing art piece.         |
| `ERR-INVALID-TITLE`   | Invalid format for title.                     |
| `ERR-INVALID-SIZE`    | Invalid value for size.                       |
| `ERR-UNAUTHORIZED-ACCESS` | Unauthorized action attempted.              |
| `ERR-INVALID-RECIPIENT` | Invalid recipient for transfer.              |
| `ERR-OWNER-ONLY-ACTION` | Action restricted to the owner only.          |
| `ERR-NO-ACCESS-PERMISSION` | No access permission for the user.         |

---

## Contract Storage

### Variables
- `total-art-pieces` (uint): Tracks the total number of NFTs.

### Mappings
1. **Art Storage**
   - Key: `{ art-id: uint }`
   - Value:
     ```json
     {
       "title": "string",
       "creator": "principal",
       "size": "uint",
       "creation-time": "uint",
       "description": "string",
       "tags": ["string"]
     }
     ```

2. **Access Control**
   - Key: `{ art-id: uint, user: principal }`
   - Value:
     ```json
     { "has-access": "bool" }
     ```

---

## Functions

### 1. **Create Art**
**Signature**: 
```clarity
(define-public (create-art (title (string-ascii 64)) (size uint) (description (string-ascii 128)) (tags (list 10 (string-ascii 32)))) -> uint)
```
- Validates inputs and creates a new NFT.
- Automatically assigns the creator as the owner and grants access.

### 2. **Transfer Ownership**
**Signature**:
```clarity
(define-public (transfer-ownership (art-id uint) (new-owner principal)) -> bool)
```
- Allows the current owner to transfer the NFT to another user.

### 3. **Update Art**
**Signature**:
```clarity
(define-public (update-art (art-id uint) (new-title (string-ascii 64)) (new-size uint) (new-description (string-ascii 128)) (new-tags (list 10 (string-ascii 32)))) -> bool)
```
- Updates metadata of an NFT.
- Only the owner can perform this action.

### 4. **Delete Art**
**Signature**:
```clarity
(define-public (delete-art (art-id uint)) -> bool)
```
- Deletes an NFT from storage.
- Only the owner can perform this action.

---

## Access Control

### Ownership
- The **creator** is assigned ownership upon creation.
- Only the **owner** can:
  - Update metadata.
  - Transfer ownership.
  - Delete an NFT.

### Permissions
- The contract includes a mapping to track user access for each NFT.
- Only users with explicit access can view or interact with specific NFTs.

---

## Usage Instructions

1. **Deploy the Contract**
   - Deploy this Clarity smart contract on the Stacks blockchain.

2. **Create a New NFT**
   - Use the `create-art` function to add an NFT:
     ```clarity
     (create-art "Mona Lisa" u500 "Famous painting by Da Vinci" ["classic" "masterpiece"])
     ```

3. **Transfer Ownership**
   - Transfer the NFT to another user:
     ```clarity
     (transfer-ownership u1 'SP1234567890ABCDEF)
     ```

4. **Update Metadata**
   - Modify an NFT's metadata:
     ```clarity
     (update-art u1 "Mona Lisa (Updated)" u600 "Updated description" ["classic" "art"])
     ```

5. **Delete an NFT**
   - Remove an NFT from the collection:
     ```clarity
     (delete-art u1)
     ```

---

## Security Considerations

- **Ownership Checks**: The contract ensures only authorized users can modify or delete NFTs.
- **Validation**: All inputs are validated to maintain data integrity (e.g., proper title length, valid tags).
- **Error Handling**: Detailed error codes provide clarity on failed operations.

---

## License

This project is licensed under the **MIT License**. See the `LICENSE` file for more details.
```

This `README.md` includes comprehensive details about the smart contract, including its purpose, features, functionalities, usage, and security considerations. It provides all the information a developer or user would need to understand and interact with your contract.