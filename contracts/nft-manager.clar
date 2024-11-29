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

;; -----------------------------
;; Helper Functions
;; -----------------------------
;; Check if the art piece exists in the storage
(define-private (art-exists? (art-id uint))
  (is-some (map-get? art-storage { art-id: art-id }))
)

;; Check if the given user is the owner of the art piece
(define-private (is-art-owner? (art-id uint) (creator principal))
  (match (map-get? art-storage { art-id: art-id })
    art-data (is-eq (get creator art-data) creator)  ;; Compare creator's address
    false
  )
)

;; Get the size of the art piece
(define-private (get-art-size (art-id uint))
  (default-to u0 
    (get size 
      (map-get? art-storage { art-id: art-id })
    )
  )
)

;; Validate the format of a single tag
(define-private (is-valid-tag? (tag (string-ascii 32)))
  (and 
    (> (len tag) u0)     ;; Tag length must be greater than 0
    (< (len tag) u33)    ;; Tag length must be less than 33
  )
)

;; Validate the collection of tags
(define-private (are-tags-valid? (tags (list 10 (string-ascii 32))))
  (and
    (> (len tags) u0)                 ;; Must contain at least one tag
    (<= (len tags) u10)               ;; Must contain no more than 10 tags
    (is-eq (len (filter is-valid-tag? tags)) (len tags))  ;; Ensure all tags are valid
  )
)

;; -----------------------------
;; Public Functions
;; -----------------------------
;; Create a new art entry
(define-public (create-art (title (string-ascii 64)) (size uint) (description (string-ascii 128)) (tags (list 10 (string-ascii 32))))
  (let
    (
      (new-art-id (+ (var-get total-art-pieces) u1))  ;; Generate new art ID by incrementing total art count
    )
    ;; Validate inputs
    (asserts! (and (> (len title) u0) (< (len title) u65)) ERR-INVALID-TITLE)  ;; Title must be between 1 and 64 characters
    (asserts! (and (> size u0) (< size u1000000000)) ERR-INVALID-SIZE)          ;; Size must be a positive value
    (asserts! (and (> (len description) u0) (< (len description) u129)) ERR-INVALID-TITLE)  ;; Description must be between 1 and 128 characters
    (asserts! (are-tags-valid? tags) ERR-INVALID-TITLE)  ;; Validate tags
    
    ;; Store the new art entry
    (map-insert art-storage
      { art-id: new-art-id }
      {
        title: title,
        creator: tx-sender,
        size: size,
        creation-time: block-height,
        description: description,
        tags: tags
      }
    )

    ;; Set initial access rights (creator has access by default)
    (map-insert access-control
      { art-id: new-art-id, user: tx-sender }
      { has-access: true }
    )
    
    ;; Increment the total art piece counter
    (var-set total-art-pieces new-art-id)
    (ok new-art-id)  ;; Return the new art ID
  )
)

;; Transfer ownership of an art piece
(define-public (transfer-ownership (art-id uint) (new-owner principal))
  (let
    (
      (art-data (unwrap! (map-get? art-storage { art-id: art-id }) ERR-ART-NOT-FOUND))  ;; Retrieve the art data, or fail if not found
    )
    (asserts! (art-exists? art-id) ERR-ART-NOT-FOUND)  ;; Ensure the art exists
    (asserts! (is-eq (get creator art-data) tx-sender) ERR-UNAUTHORIZED-ACCESS)  ;; Ensure only the creator can transfer ownership
    
    ;; Update the art storage with the new owner
    (map-set art-storage
      { art-id: art-id }
      (merge art-data { creator: new-owner })  ;; Update the creator field
    )
    (ok true)  ;; Indicate success
  )
)

;; Update the details of an existing art piece
(define-public (update-art (art-id uint) (new-title (string-ascii 64)) (new-size uint) (new-description (string-ascii 128)) (new-tags (list 10 (string-ascii 32))))
  (let
    (
      (art-data (unwrap! (map-get? art-storage { art-id: art-id }) ERR-ART-NOT-FOUND))  ;; Retrieve the art data
    )
    ;; Validation checks
    (asserts! (art-exists? art-id) ERR-ART-NOT-FOUND)  ;; Ensure the art exists
    (asserts! (is-eq (get creator art-data) tx-sender) ERR-UNAUTHORIZED-ACCESS)  ;; Ensure the creator is the sender
    (asserts! (and (> (len new-title) u0) (< (len new-title) u65)) ERR-INVALID-TITLE)  ;; Validate the new title
    (asserts! (and (> new-size u0) (< new-size u1000000000)) ERR-INVALID-SIZE)  ;; Validate the new size
    (asserts! (and (> (len new-description) u0) (< (len new-description) u129)) ERR-INVALID-TITLE)  ;; Validate the new description
    (asserts! (are-tags-valid? new-tags) ERR-INVALID-TITLE)  ;; Validate the new tags
    
    ;; Update the art data in storage
    (map-set art-storage
      { art-id: art-id }
      (merge art-data { 
        title: new-title, 
        size: new-size, 
        description: new-description, 
        tags: new-tags 
      })
    )
    (ok true)  ;; Indicate success
  )
)

;; Delete an art piece from storage
(define-public (delete-art (art-id uint))
  (let
    (
      (art-data (unwrap! (map-get? art-storage { art-id: art-id }) ERR-ART-NOT-FOUND))  ;; Retrieve the art data
    )
    (asserts! (art-exists? art-id) ERR-ART-NOT-FOUND)  ;; Ensure the art exists
    (asserts! (is-eq (get creator art-data) tx-sender) ERR-UNAUTHORIZED-ACCESS)  ;; Ensure only the creator can delete the art
    
    ;; Remove the art from storage
    (map-delete art-storage { art-id: art-id })
    (ok true)  ;; Indicate success
  )
)