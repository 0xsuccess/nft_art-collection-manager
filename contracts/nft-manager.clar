;; NFT Collection Manager Contract
;; This smart contract is designed to manage the storage, access control, and operations for a collection of digital art NFTs.
;; It allows the creation, update, transfer, and deletion of art pieces, with support for ownership management and access control.
;; Each art piece is uniquely identified by an ID and includes metadata such as title, creator, size, description, and associated tags.
;; The contract ensures that only authorized users (e.g., the creator or owner) can modify or transfer ownership of an art piece.
;; Additionally, the contract provides functionality to validate and enforce proper formats for art details, including title, size, and tags.

;; -----------------------------
;; Constants
;; -----------------------------
(define-constant CONTRACT-OWNER tx-sender)  ;; The contract owner (set to the transaction sender)

;; Error codes
(define-constant ERR-ART-NOT-FOUND (err u301))        ;; Error when art piece is not found
(define-constant ERR-DUPLICATE-ART (err u302))        ;; Error when trying to add an already existing art piece
(define-constant ERR-INVALID-TITLE (err u303))       ;; Error when the title format is invalid
(define-constant ERR-INVALID-SIZE (err u304))        ;; Error when the art size value is invalid
(define-constant ERR-UNAUTHORIZED-ACCESS (err u305))  ;; Error when the user is unauthorized to perform the action
(define-constant ERR-INVALID-RECIPIENT (err u306))    ;; Error when the recipient is invalid
(define-constant ERR-OWNER-ONLY-ACTION (err u307))    ;; Error when action is restricted to the owner only
(define-constant ERR-NO-ACCESS-PERMISSION (err u308)) ;; Error when the user has no access permission

;; -----------------------------
;; Storage Variables
;; -----------------------------
;; Track the total number of art pieces in the collection
(define-data-var total-art-pieces uint u0)

;; Main storage for individual art pieces
(define-map art-storage
  { art-id: uint }  ;; Each art piece is identified by its unique art ID
  {
    title: (string-ascii 64),         ;; Title of the art piece
    creator: principal,               ;; Creator (owner) of the art piece
    size: uint,                       ;; Size of the art piece
    creation-time: uint,              ;; Block height at the time of creation
    description: (string-ascii 128),  ;; Description of the art piece
    tags: (list 10 (string-ascii 32)) ;; List of tags associated with the art piece
  }
)

;; Access control mapping: Defines who has access to a particular art piece
(define-map access-control
  { art-id: uint, user: principal }  ;; Art ID and user combination
  { has-access: bool }               ;; True if the user has access, otherwise False
)
