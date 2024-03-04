;;; org-roam-anki-capture.el --- capture anki flashcards that links to org-roam notes  -*- lexical-binding: t; -*-
;; Package-Requires: ((org-roam) (anki-editor))
;; Copyright (C) 2024  

;; Author: Xephobia
;;; Commentary:
;; A way to capture Anki flashcards from org-roam nodes that links to where you were, using anki-editor
;;; Code:

(require 'org-roam)
(require 'anki-editor)

(defcustom org-roam-anki-capture-directory "anki_notes/"
  "Where are the anki notes stored, relative to org-roam-directory."
  :type '(string))

(defun org-roam-anki--get-contents ()
  (let*
    ((deck
      (completing-read "Deck: "
		       (anki-editor-deck-names)))
     (type
      (completing-read "Note type: "
		       (anki-editor-note-types)))
     (fields
      (anki-editor-api-call-result 'modelFieldNames :modelName type)))
  (with-temp-buffer
    (org-mode)
    (org-insert-heading)
    (org-edit-headline "%a")
    (dolist
	(field fields)
      (org-insert-heading)
      (org-edit-headline field)
      (if
	  (eq (car fields) field)
	  (org-do-demote))
      (insert
       (concat "\n"
	       (read-string
		(format "contents of field %s:" field)))))
    (buffer-substring-no-properties
     (point-min)
     (point-max)))))

(defun org-roam-anki-capture--get-template ()
   `(("a" "anki card" plain #'org-roam-anki--get-contents
	 :target (file ,(file-name-concat org-roam-anki-capture-directory "${id}.org"))))
    

(defun org-roam-anki-capture-current-file (&optional goto keys)
  (interactive)
  (let ((org-roam-directory (expand-file-name org-roam-anki-directory org-roam-directory)))
    (org-roam-capture- :goto (when goto '(4))
		       :keys keys
		       :node (org-roam-node-create)
		       :templates org-roam-anki-capture-templates)))

(provide 'org-roam-anki-capture)

;;; org-roam-anki-capture.el ends here
