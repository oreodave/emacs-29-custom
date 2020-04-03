;;; arc-mode.el --- simple editing of archives  -*- lexical-binding: t; -*-
;;			Arc	Lzh	Zip	Zoo	Rar	7z	Ar
;;			--------------------------------------------------
;; View listing		Intern	Intern	Intern	Intern	Y	Y	Y
;; Extract member	Y	Y	Y	Y	Y	Y	Y
;; Save changed member	Y	Y	Y	Y	N	Y	Y
;; Add new member	N	N	N	N	N	N	N
;; Delete member	Y	Y	Y	Y	N	Y	N
;; Rename member	Y	Y	N	N	N	N	N
;; Chmod		-	Y	Y	-	N	N	N
;; Chown		-	Y	-	-	N	N	N
;; Chgrp		-	Y	-	-	N	N	N
(eval-when-compile (require 'cl-lib))

  :type 'directory)
  :type 'regexp)
  :type 'hook)
                 (const :tag "Show the archive summary" nil)))
(defgroup archive-arc nil
  "ARC-specific options to archive."
  :group 'archive)

			(string :format "%v"))))
			(string :format "%v"))))
			(string :format "%v"))))
(defgroup archive-lzh nil
  "LZH-specific options to archive."
  :group 'archive)

			(string :format "%v"))))
			(string :format "%v"))))
			(string :format "%v"))))
(defgroup archive-zip nil
  "ZIP-specific options to archive."
  :group 'archive)

		       (string :format "%v"))))
		       (string :format "%v"))))
		       (string :format "%v"))))
		       (string :format "%v"))))
  :version "27.1")
(defgroup archive-zoo nil
  "ZOO-specific options to archive."
  :group 'archive)

			(string :format "%v"))))
			(string :format "%v"))))
			(string :format "%v"))))
(defgroup archive-7z nil
  "7Z-specific options to archive."
  :group 'archive)

		       (string :format "%v"))))
		       (string :format "%v"))))
		       (string :format "%v"))))
(defvar-local archive-local-name nil "Name of local copy of remote archive.")
(defvar-local archive-subfile-mode nil
  "Non-nil in archive member buffers.
Its value is an `archive--file-desc'.")
(cl-defstruct (archive--file-desc
               (:constructor nil)
               (:constructor archive--file-desc
                ;; ext-file-name and int-file-name are usually `eq'
                ;; except when int-file-name is the downcased
                ;; ext-file-name.
                (ext-file-name int-file-name mode)))
  ext-file-name int-file-name mode)

;; Features in formats:
;;
;; ARC: size, date, time (date and time strings internally generated)
;; LZH: size, date, time, mode, uid, gid (mode, date, time generated, ugid:int)
;; ZIP: size, date, time, mode (mode, date, time generated)
;; ZOO: size, date, time (date and time strings internally generated)
;; AR : size, date, time, mode, user, group (internally generated)
;; RAR: size, date, time, ratio (all as strings, using `lsar')
;; 7Z : size, date, time (all as strings, using `7z' or `7za')
;;
;; LZH has alternate display (with UID/GID i.s.o MODE/DATE/TIME

  "Vector of `archive--file-desc' objects.")
    (insert (if (and (integerp elt) (>= elt 128))
                (decode-char 'eight-bit elt)
              elt))))
  (if (null mode)
      "??????????"
    (string
     (if (zerop (logand  8192 mode))
	 (if (zerop (logand 16384 mode)) ?- ?d)
       ?c)                              ; completeness
     (if (zerop (logand   256 mode)) ?- ?r)
     (if (zerop (logand   128 mode)) ?- ?w)
     (if (zerop (logand    64 mode))
	 (if (zerop (logand  2048 mode)) ?- ?S)
       (if (zerop (logand  2048 mode)) ?x ?s))
     (if (zerop (logand    32 mode)) ?- ?r)
     (if (zerop (logand    16 mode)) ?- ?w)
     (if (zerop (logand     8 mode))
	 (if (zerop (logand  1024 mode)) ?- ?S)
       (if (zerop (logand  1024 mode)) ?x ?s))
     (if (zerop (logand     4 mode)) ?- ?r)
     (if (zerop (logand     2 mode)) ?- ?w)
     (if (zerop (logand     1 mode)) ?- ?x))))

(defun archive-calc-mode (oldmode newmode)
OLDMODE will be modified accordingly just like chmod(2) would have done."
  ;; FIXME: Use `file-modes-symbolic-to-number'!
  (if (string-match "\\`0[0-7]*\\'" newmode)
      (logior (logand oldmode #o177000) (string-to-number newmode 8))
    (file-modes-symbolic-to-number newmode oldmode)))
                     "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"]
                    (1- month))
	  (if (archive--file-desc-p item)
      (funcall (or (default-value 'major-mode) #'fundamental-mode))
	(setq-local archive-subtype type)
	(add-function :around (local 'revert-buffer-function)
	              #'archive--mode-revert)
	(add-hook 'write-contents-functions #'archive-write-file nil t)
        (setq-local truncate-lines t)
	(setq-local require-final-newline nil)
	(setq-local local-enable-local-variables nil)
	(setq-local file-precious-flag t)
	(setq-local archive-read-only
		    (or (not (file-writable-p (buffer-file-name)))
		        (and archive-subfile-mode
		             (string-match file-name-invalid-regexp
				           (archive--file-desc-ext-file-name
				            archive-subfile-mode)))))
	(setq major-mode #'archive-mode)
    (add-hook 'change-major-mode-hook #'archive-desummarize nil t)
(cl-defstruct (archive--file-summary
               (:constructor nil)
               (:constructor archive--file-summary (text name-start name-end)))
  text name-start name-end)

  ;; Here we assume that they all start at the same column.
  (setq archive-file-name-indent
        ;; FIXME: We assume chars=columns (no double-wide chars and such).
        (if files (archive--file-summary-name-start (car files)) 0))
   (mapconcat
    (lambda (fil)
      ;; Using `concat' here copies the text also, so we can add
      ;; properties without problems.
      (let ((text (concat (archive--file-summary-text fil) "\n")))
        (add-text-properties
         (archive--file-summary-name-start fil)
         (archive--file-summary-name-end fil)
         '(mouse-face highlight
           help-echo "mouse-2: extract this file into a buffer")
         text)
        text))
    files
    ""))
	       (or (and archive-subfile-mode (archive--file-desc-ext-file-name
		                              archive-subfile-mode))
  (or (eq op #'file-exists-p)
         (ename (archive--file-desc-ext-file-name descr))
         (iname (archive--file-desc-int-file-name descr))
  (let* ((ename (archive--file-desc-ext-file-name descr))
	  (if (archive--file-desc-mode descr)
	      (set-file-modes tmpfile
	                      (logior ?\400 (archive--file-desc-mode descr))))
  (interactive "sNew mode (octal or symbolic): ")
	    (setq files (cons (archive--file-desc-ext-file-name
	                       (archive-get-descr))
	                      files)))
(defun archive--mode-revert (orig-fun &rest args)
    (let ((coding-system-for-read 'no-conversion))
      (apply orig-fun t t (cddr args)))
(cl-defstruct (archive-arc--file-desc
               (:include archive--file-desc)
               (:constructor nil)
               (:constructor archive-arc--file-desc
                (ext-file-name int-file-name mode pos)))
  pos)

	      visual (cons (archive--file-summary
			    text
			    (- (length text) (length ifnname))
			    (length text))
	      files (cons (archive-arc--file-desc
                           efnname ifnname nil (1- p))
  (let ((name (concat newname (make-string (- 13 (length newname)) ?\0)))
	(goto-char (+ archive-proper-file-start 2
	              (archive-arc--file-desc-pos descr)))
(cl-defstruct (archive-lzh--file-desc
               (:include archive--file-desc)
               (:constructor nil)
               (:constructor archive-lzh--file-desc
                (ext-file-name int-file-name mode pos)))
  pos)

	(setq modestr (archive-int-to-mode mode))
	      visual (cons (archive--file-summary
			    text
			    (- (length text) (length prname))
			    (length text))
	      files (cons (archive-lzh--file-desc
                           prname ifnname mode (1- p))
      (let* ((p        (+ archive-proper-file-start
	                  (archive-lzh--file-desc-pos descr)))
	(let* ((p (+ archive-proper-file-start (archive-lzh--file-desc-pos fil)))
		     (archive--file-desc-int-file-name fil) errtxt)))))))
   (lambda (old) (archive-calc-mode old newmode))
(cl-defstruct (archive-zip--file-desc
               (:include archive--file-desc)
               (:constructor nil)
               (:constructor archive-zip--file-desc
                (ext-file-name int-file-name mode pos)))
  pos)

             ;; (lheader (archive-l-e (+ p 42) 4))
	     (modestr (archive-int-to-mode mode))
			   (memq creator '(0 2 4 5 9))
	      visual (cons (archive--file-summary
			    text
			    (- (length text) (length ifnname))
			    (length text))
			    (archive-zip--file-desc efnname ifnname mode
				                    (1- p)))
(defun archive--file-desc-case-fiddled (fd)
  (not (eq (archive--file-desc-int-file-name fd)
           (archive--file-desc-ext-file-name fd))))

   (if (archive--file-desc-case-fiddled descr)
       archive-zip-update-case archive-zip-update)))
	(let* ((p (+ archive-proper-file-start
	             (archive-zip--file-desc-pos fil)))
	       (oldmode (archive--file-desc-mode fil))
	       (newval  (archive-calc-mode oldmode newmode))
	      visual (cons (archive--file-summary
			    text
			    (- (length text) (length ifnname))
			    (length text))
	      ;; FIXME: Keep size/date(/mode?) in the desc!
	      files (cons (archive--file-desc efnname ifnname nil)
(cl-defstruct (archive-rar--file-desc
               (:include archive--file-desc)
               (:constructor nil)
               (:constructor archive-rar--file-desc
                (ext-file-name int-file-name mode size ratio date time)))
  size ratio date time)

          (push (archive-rar--file-desc name name nil
                                        ;; Size, Ratio.
                                        size (match-string 2)
                                        ;; Date, Time.
                                        (match-string 4) (match-string 5))
      (archive-summarize-files
       (mapcar (lambda (desc)
                 (let ((text
                        (format format
                                (archive-rar--file-desc-date desc)
                                (archive-rar--file-desc-time desc)
                                (archive-rar--file-desc-size desc)
                                (archive-rar--file-desc-ratio desc)
                                (archive--file-desc-int-file-name desc))))
                   (archive--file-summary
                    text
                    column
                    (length text))))
               files))
(cl-defstruct (archive-7z--file-desc
               (:include archive--file-desc)
               (:constructor nil)
               (:constructor archive-7z--file-desc
                (ext-file-name int-file-name mode time size)))
  time size)

          (push (archive-7z--file-desc name name nil time size)
      (archive-summarize-files
       (mapcar (lambda (desc)
                 (let ((text
                        (format format
				(archive-7z--file-desc-size desc)
				(archive-7z--file-desc-time desc)
				(archive--file-desc-int-file-name desc))))
                   (archive--file-summary
                    text column (length text))))
               files))
(cl-defstruct (archive-ar--file-desc
               (:include archive--file-desc)
               (:constructor nil)
               (:constructor archive-ar--file-desc
                (ext-file-name int-file-name mode time user group size)))
  time user group size)

(defun archive-ar--name (name)
  "Return the external name represented by the entry NAME.
NAME is expected to be the 16-bytes part of an ar record."
  (cond ((equal name "//              ")
         (propertize ".<ExtNamesTable>." 'face 'italic))
        ((equal name "/               ")
         (propertize ".<LookupTable>." 'face 'italic))
        ((string-match "/? *\\'" name)
         ;; FIXME: Decode?  Add support for longer names?
         (substring name 0 (match-beginning 0)))))

        (setq extname (archive-ar--name name))
        (setq mode (archive-int-to-mode mode))
        (push (archive-ar--file-desc extname extname mode
                                     time user group size)
      (archive-summarize-files
       (mapcar (lambda (desc)
                 (let ((text
                        (format format
                                (archive--file-desc-mode desc)
                                (archive-ar--file-desc-user desc)
                                (archive-ar--file-desc-group desc)
                                (archive-ar--file-desc-size desc)
                                (archive-ar--file-desc-time desc)
                                (archive--file-desc-int-file-name desc))))
                   (archive--file-summary text column (length text))))
               files))
              (if (equal name (archive-ar--name this))
(defun archive-ar-write-file-member (archive descr)
  (archive-*-write-file-member
   archive
   (let ((d (copy-sequence descr)))
     ;; FIXME: Crude conversion from string modes to a number.
     (cl-callf (lambda (s) (if (string-match "x" s) ?\555 ?\444))
         (archive--file-desc-mode d))
     d)
   '("ar" "r")))

