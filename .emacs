;;;Paul Santa Clara's emacs file

(require 'cl)

;;;default to text mode
(setq default-major-mode 'text-mode )
(add-hook 'text-mode-hook 'text-mode-hook-identify )
(add-hook 'text-mode-hook 'turn-on-auto-fill)


(defvar *krbemacs-home*
  (let* ((candidate-path (replace-regexp-in-string "/$" "" (file-name-directory (file-chase-links (expand-file-name "~/.emacs")))))
         (test-file (format "%s/lib/krb/krb-misc.el" candidate-path)))
    (cond ((file-exists-p test-file)
           candidate-path)
          (t
           (error  "Unable to find the location of the emacs package (assuming you've pulled from git://github.com/kyleburton/krbemacs).  Please see your ~/.emacs file and add a default location."))))
  "The install location of my emacs configuration.  All other
  modules will be relative to this location.")

(defun krb-file (file)
  "Helper for locating files relative to the installation root."
  (concat *krbemacs-home* "/" file))


(defun krb-file-newer (f1 f2)
  (let ((f1-mtime (nth 5 (file-attributes f1)))
        (f2-mtime (nth 5 (file-attributes f2))))
    (cond ((> (car f1-mtime)
              (car f2-mtime))
           t)
          ((< (car f1-mtime)
              (car f2-mtime))
           nil)
          ((> (cadr f1-mtime)
              (cadr f2-mtime))
           t)
          (t
           nil))))


(defun krb-compile-el-files-in-library (library-path)
  (dolist (file (directory-files (krb-file (format "%s/" library-path)) t "^[^#]+\\.el$"))
    (let ((cfile (format "%sc" file)))
      (when (or (not (file-exists-p cfile))
                (krb-file-newer file cfile))
        (byte-compile-file file)))))


(defvar *lib-dirs*
  '("lib"
    "lib/krb/"
    "lib/clojure-mode/"
    "lib/slime/"
    "lib/swank-clojure/"
    "lib/autocomplete/"
    "lib/ac-slime/"

;;     "ruby-mode"
;;     "yasnippet"
)
  "List of lib directories.")

;; add those all to the lib path
(mapcar #'(lambda (path)
            (add-to-list 'load-path (krb-file path)))
        *lib-dirs*)


(global-set-key "\M-g" 'goto-line)

;;;;toggle case love-in
(global-set-key "\C-c~" 'joc-toggle-case)
(load "toggle-case.el")


(global-set-key "\C-cr\\" 'krb-reindent-entire-buffer)



;; keyboard customziation for window movement like VIM's, you know,
;; b/c vim is da bmomb!
;;    h : move left
;;    j : move down
;;    k : move up
;;    l : move right
(define-prefix-command 'krb-windowing-keyboard-map)
(global-set-key (kbd "C-x w") 'krb-windowing-keyboard-map)
(define-key krb-windowing-keyboard-map (kbd "h") 'windmove-left)
(define-key krb-windowing-keyboard-map (kbd "j") 'windmove-down)
(define-key krb-windowing-keyboard-map (kbd "k") 'windmove-up)
(define-key krb-windowing-keyboard-map (kbd "l") 'windmove-right)

;;turn on ido
(require 'ido)
(ido-mode t)

(krb-compile-el-files-in-library "lib")
(krb-compile-el-files-in-library "lib/krb")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lisp Stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;swank-clojure
(setq swank-clojure-binary "clojure")
(krb-compile-el-files-in-library "lib/swank-clojure")
(add-hook 'slime-repl-mode-hook 'clojure-mode-font-lock-setup)
(require 'swank-clojure-autoload)

;;give me slime
(krb-compile-el-files-in-library "lib/slime")

(require 'slime)

(eval-after-load "slime"
  '(progn
     (slime-setup '(slime-repl))))


;;give me paredit
(require 'paredit)

;;turn it on for elisp
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (paredit-mode +1)
            (setq abbrev-mode t)))

;;turn it on for cl
(add-hook 'lisp-mode-hook
          (lambda ()
            (paredit-mode +1)
            (setq abbrev-mode t)))

;;turn it on for clojure
(add-hook 'clojure-mode-hook
	  (lambda ()
	    (paredit-mode +1)
	    ;;(yas/minor-mode-on)
	    ;; (local-set-key "\C-cr"  krb-clj-mode-prefix-map)
))

;;we like kill-sexp
(add-hook 'paredit-mode-hook
          (lambda ()
            (local-set-key "\M-k" 'kill-sexp)))

(add-hook 
 'paredit-mode-hook 
 '(lambda ()
    (local-set-key "\M-Oa" 'paredit-splice-sexp-killing-backward)
    (local-set-key "\M-Ob" 'paredit-splice-sexp-killing-forward)
    (local-set-key "\M-Oc" 'paredit-forward-slurp-sexp)
    (local-set-key "\M-Od" 'paredit-forward-barf-sexp)
    (rainbow-delimiters-mode t)
    (rainbow-paren-mode)
    (setq abbrev-mode t)))

;;clojure mode
(krb-compile-el-files-in-library "lib/clojure-mode")
(require 'clojure-mode)
(require 'rainbow-delimiters)
(require 'rainbow-parens)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End Lisp Stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (krb-compile-el-files-in-library "yasnippet")
;; (krb-compile-el-files-in-library "scala-mode")
;; (krb-compile-el-files-in-library "ruby-mode")

;;make things pretty
(krb-compile-el-files-in-library "lib/themes")
(require 'color-theme)

(color-theme-initialize)
(load "themes/blackbored.el")
(color-theme-blackbored)

;;highlight current line
(global-hl-line-mode 1)

(set-face-background 'hl-line "#333333")

;;set cursor colour(doesn't work with iterm :(
(set-cursor-color "yellow")

;;make sure ansi colour character escapes are honoured
(ansi-color-for-comint-mode-on)

;;hide menu bar
(menu-bar-mode -1)

;;autocomplete
(krb-compile-el-files-in-library "lib/autocomplete")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; auto complete stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'auto-complete)
(require 'auto-complete-config)

(add-to-list 'ac-dictionary-directories
	     (concat *krbemacs-home* "/lib/autocomplete/dict"))
(ac-config-default)

(set-default 'ac-sources
             '(ac-source-dictionary
               ac-source-words-in-buffer
               ac-source-words-in-same-mode-buffers
               ac-source-words-in-all-buffer
	       ac-source-functions))

(setq ac-use-quick-help t)
(setq ac-quick-help-delay 1)


(global-auto-complete-mode t)
(setq ac-quick-help-delay 1)
(setq ac-quick-help-height 60)
(setq ac-use-menu-map t)

;; (define-key ac-menu-map (kbd "C-c h") 'ac-help)
(ac-help 'interactive)

;;hook slime into autocomplete
(krb-compile-el-files-in-library "lib/ac-slime")
(require 'ac-slime)
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(setq ac-sources (cons 'ac-source-slime-simple ac-sources))



