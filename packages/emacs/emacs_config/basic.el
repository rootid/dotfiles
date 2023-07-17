;; Customize the UI
(setq inhibit-startup-message t) ; Disable startup message
(tooltip-mode -1) ; Disable tooltips
(menu-bar-mode -1) ; Disable the menu bar

;; Fix backup files and directories
;; (setq auto-save-default nil) ;; Do not create autosave (filename~) files
(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/autosaves/" t))) ; store autosave files in autosave directory, Prereq - make sure dir is created

;; TODO - how to pull all the theme to test/evaluate?
;;(use-package doom-themes
;;    :config
;;    (load-theme 'doom-wilmersdorf t))

;; Fix all icon issue
;;(use-package all-the-icons
;;  :ensure t)
;;(use-package doom-modeline
;;    :ensure t
;;    :init (doom-modeline-mode 1)
;;    :custom ((doom-modeline-height 15)))

(use-package 
  iodine-theme 
  :config (load-theme 'iodine t))

;;(column-number-mode) ; Show colum number 
;;(global-display-line-numbers-mode t) ; display line number 
;; Example of interactive command
(defun my-greet-user (name) 
  "Greet the user by name." 
  (interactive "sEnter your name: ") 
  (message "Hello, %s!" name))

(global-set-key (kbd "C-c g") 'my-greet-user)

;; To view the commands executed on right panel 
;; TODO : Fix me - looks like it's not working as expected
(use-package 
  command-log-mode 
  :ensure t)

;; Package for command completion, different packges can be used with ivy e.g. counsel and other alterntives are helm, ido (TODO: Explore these packages)
(use-package 
  ivy 
  :ensure t
  ;;:diminish
  :bind 
   (("C-s" . swiper) :map ivy-minibuffer-map ("TAB" . ivy-alt-done) 
	 ("C-l" . ivy-alt-done) 
	 ("C-j" . ivy-next-line) 
	 ("C-k" . ivy-previous-line) 
	 :map ivy-switch-buffer-map ("C-k" . ivy-previous-line) 
	 ("C-l" . ivy-done) 
	 ("C-d" . ivy-switch-buffer-kill) 
	 :map ivy-reverse-i-search-map ("C-k" . ivy-previous-line) 
	 ("C-d" . ivy-reverse-i-search-kill)) 
  :config (ivy-mode 1))

;; on-the-fly keybinding suggestions in the minibuffer
(use-package 
  which-key 
  :ensure t 
  :init (which-key-mode) 
  :diminish which-key-mode 
  :config (setq which-key-idle-delay 1))

;; Enhances the visual appearance of Ivy completion and selection menus.
(use-package 
  ivy-rich 
  :ensure t 
  :init (ivy-rich-mode 1)
  :config
  (setq ivy-rich-display-transformers-list
      '(counsel-M-x
        (:columns
         ((counsel-M-x-transformer (:width 40))
          (ivy-rich-counsel-function-docstring (:face font-lock-doc-face))))))
)

;; collection of enhanced completion and selection utilities for Emacs
(use-package 
  counsel 
  :ensure t 
  :bind (
	 ;("M-x" . counsel-M-x)
   ("C-x b" . counsel-ibuffer) 
	 ("C-x C-f" . counsel-find-file) 
	 :map minibuffer-local-map ("C-r" . 'counsel-minibuffer-history)) 
  :config (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with

;; 3 Types of key bindigs
;; key binding types
(global-set-key (kbd "C-c C-f") 'find-file) ;; global
(define-key emacs-lisp-mode-map (kbd "C-c C-e") 'eval-buffer) ;; use keymap

;; TODO : Explore evil collections and how to use it
(defun vs/evil_override_read_key_map ()
  ;; Override key bindings in `evil-read-key-map`.
  ;; Add more key bindings as needed
  ;;(define-key evil-read-key-map (kbd "jk") #'keyboard-quit)
  (define-key evil-read-key-map (kbd "C-[") #'keyboard-quit)
  (define-key evil-read-key-map (kbd "C-]") #'keyboard-quit)
  (define-key evil-read-key-map (kbd "C-g") #'keyboard-quit)
)

(defun vs/evil_init_config()
  ;; Add more key bindings as needed
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil) 
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
)

(use-package 
  evil 
  :ensure t 
  :init
  (progn (vs/evil_init_config))
  :config 
  (evil-mode 1) 
  (add-hook 'evil-read-key-map-hook 'vs/evil_override_read_key_map)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state) 
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join))

;; Set keybindings for Ivy and Counsel
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "C-c s") 'swiper)
(global-set-key (kbd "C-c g") 'counsel-rg)

;; Set other keybindings
(global-set-key (kbd "C-c f") 'find-file)
(global-set-key (kbd "C-c b") 'switch-to-buffer)
(global-set-key (kbd "C-c w") 'save-buffer)
