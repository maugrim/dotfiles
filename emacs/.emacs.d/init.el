;;; -*- no-byte-compile: t; lexical-binding: t; -*-

(defalias 'yes-or-no-p 'y-or-n-p)
(setq-default
 completion-styles '(substring)
 dired-listing-switches "-alh"
 initial-major-mode 'text-mode
 bidi-display-reordering nil
 echo-keystrokes 0.1
 message-log-max t
 mouse-wheel-mode t
 xterm-mouse-mode t
 color-theme-is-global t
 delete-by-moving-to-trash t
 font-lock-maximum-decoration t
 blink-cursor-mode -1
 visible-bell nil
 inhibit-startup-screen t
 initial-scratch-message nil
 x-select-enable-clipboard t
 x-select-enable-primary t
 save-interprogram-paste-before-kill t
 apropos-do-all t
 mouse-yank-at-point t
 vc-make-backup-files t
 custom-file (concat user-emacs-directory "custom.el")
 backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
 auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
 create-lockfiles nil
 indent-tabs-mode nil
 tab-width 4
 fill-column 120
 global-auto-revert-mode t
 require-final-newline t
 fit-window-to-buffer-horizontally "only"
 read-process-output-max (* 16 1024 1024)
 server-client-instructions nil
 read-file-name-completion-ignore-case t
 read-buffer-completion-ignore-case t
 completion-ignore-case t
 tab-always-indent 'complete)

(global-set-key (kbd "C-h a") 'apropos)
(global-set-key (kbd "M-f") 'forward-word)
(global-set-key (kbd "M-b") 'backward-word)
(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-c q") 'join-line)
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)
(global-set-key (kbd "C-x g") 'magit-status)

(when (file-exists-p custom-file) (load custom-file))
(load (concat user-emacs-directory "package-bootstrap"))
(load (concat user-emacs-directory "utils"))

(pixel-scroll-mode)
(use-package zenburn-theme :init (load-theme 'zenburn))
(use-package mood-line :init (mood-line-mode))
(set-face-attribute 'header-line nil :box nil)
(set-face-attribute 'mode-line nil :box nil)
(set-face-attribute 'mode-line-highlight nil :box nil)
(set-face-attribute 'mode-line-inactive nil :box nil)
(set-face-foreground 'vertical-border (face-attribute 'default :background))
(set-face-background 'vertical-border (face-attribute 'default :background))

;; Do not allow the cursor in the minibuffer prompt
(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; hippie-expand: at times perhaps too hip
(delete 'try-expand-line hippie-expand-try-functions-list)
(delete 'try-expand-list hippie-expand-try-functions-list)

(defun ashc (cmd)
  (interactive "sCall command: ")
  (let ((output-buffer (generate-new-buffer (format "*async:%s*" cmd)))
        (error-buffer  (generate-new-buffer (format "*error:%s*" cmd))))
    (async-shell-command cmd output-buffer error-buffer)))

;; package-specific configs follow
(require 'shell)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(require 'js)
(setq-default js-indent-level 2)
(add-hook 'js-mode-hook 'subword-mode)
(define-key js-mode-map (kbd "M-.") nil)

(require 'lisp-mode)
(add-hook 'lisp-interaction-mode-hook 'eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'pretty-lambdas)
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(add-hook 'emacs-lisp-mode-hook 'pretty-lambdas)

(require 'prog-mode)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'prog-mode-hook 'electric-pair-mode)
(add-hook 'prog-mode-hook 'electric-indent-mode)

(require 'comint)
;; sets the current buffer process to not pop up an annoying notification on Emacs exit
(add-hook
 'comint-exec-hook
 (lambda () (set-process-query-on-exit-flag (get-buffer-process (current-buffer)) nil)))

(require 'uniquify)
(setq-default
 uniquify-buffer-name-style 'forward
 uniquify-ignore-buffers-re "^\\*")

(require 'eldoc)
(setq-default eldoc-idle-delay 0)

(require 'saveplace)
(setq-default
 save-place-file (concat user-emacs-directory "places")
 save-place-mode 1)

(require 'recentf)
(add-to-list 'recentf-exclude "^/\\(?:ssh\\|su\\|sudo\\)?:")
(setq-default
 recentf-max-saved-items 500
 recentf-max-menu-items 15
 recentf-save-file (concat user-emacs-directory "recentf"))
(recentf-mode 1)

(require 'savehist)
(setq-default
 savehist-additional-variables '(search ring regexp-search-ring)
 savehist-autosave-interval 60
 savehist-file (concat user-emacs-directory "savehist"))
(savehist-mode 1)

(require 'paren)
(setq-default show-paren-style 'parenthesis)
(show-paren-mode 1)

(setq-default css-indent-offset 2)

(use-package wgsl-mode
  :straight (:host github :repo "acowley/wgsl-mode")
  :mode "\\.wgsl$")

(use-package ligature
  :straight (:host github :repo "mickeynp/ligature.el")
  :init (global-ligature-mode t)
  :config
  ;; fira code has so many ligatures but they are ugly... I only like these ones
  (ligature-set-ligatures 'prog-mode '("/*" "*/" "//" "///" ";;"
                                       "||" "&&" "??" "::" ">>" "<<" "++" "--")))

(use-package rainbow-mode
  :custom (rainbow-x-colors nil)
  :hook prog-mode)

(use-package vertico
  :straight (vertico :files (:defaults "extensions/*")
                     :includes (vertico-indexed
                                vertico-flat
                                vertico-grid
                                vertico-mouse
                                vertico-quick
                                vertico-buffer
                                vertico-repeat
                                vertico-reverse
                                vertico-directory
                                vertico-multiform
                                vertico-unobtrusive))
  :init
  (vertico-mode)
  (vertico-multiform-mode)
  :config
  (setq vertico-count 10)
  (setq vertico-multiform-commands
                '((consult-buffer (vertico-count . 20))
                  (execute-extended-command flat)
                  ("magit-" flat)))
  ;; Prefix the current candidate with “» ”. From
  ;; https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "» " 'face 'vertico-current)
                   "  ")
                 cand))))

(use-package vertico-flat
  :after vertico
  :bind (:map vertico-flat-map ("TAB" . vertico-next)))

(use-package consult
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-recent-file
   consult--source-project-recent-file
   :preview-key (kbd "M-."))
  (setq consult-narrow-key "<"))

(use-package marginalia
  :bind (:map minibuffer-local-map ("M-A" . marginalia-cycle))
  :custom (marginalia-max-relative-age 0)
  :init (marginalia-mode))

(use-package embark
  :bind (("C-." . embark-act)
         ("M-." . embark-dwim)
         ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult :after (embark consult))

(use-package so-long :init (global-so-long-mode))

(require 'fsr-mode)
(add-to-list 'auto-mode-alist '("firestore\\.rules$" . fsr-mode))

(use-package vterm
  :config
  (setq-default vterm-buffer-name-string "vterm %s"
                vterm-always-compile-module t
                vterm-max-scrollback 10000))

(use-package tree-sitter
  :init (global-tree-sitter-mode)
  :config
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs
  :after tree-sitter
  :config
  (add-to-list 'tree-sitter-major-mode-language-alist '(typescript-tsx-mode . tsx))
  (tree-sitter-require 'tsx))

(use-package typescript-mode
  :after tree-sitter
  :mode "\\.ts$"
  :init
  (define-derived-mode typescript-tsx-mode typescript-mode "TSX"
    "Major mode for editing TSX files.")
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode))
  :config
  (add-hook 'typescript-mode-hook 'subword-mode)
  (add-hook 'typescript-mode-hook 'lsp)
  (setq-default typescript-indent-level 2))

(use-package tsi
  :straight (:host github :repo "orzechowskid/tsi.el")
  :after tree-sitter
  ;; define autoload definitions which when actually invoked will cause package to be loaded
  :commands (tsi-typescript-mode tsi-json-mode tsi-css-mode)
  :init
  (add-hook 'typescript-mode-hook (lambda () (tsi-typescript-mode 1)))
  (add-hook 'json-mode-hook (lambda () (tsi-json-mode 1)))
  (add-hook 'css-mode-hook (lambda () (tsi-css-mode 1)))
  (add-hook 'scss-mode-hook (lambda () (tsi-scss-mode 1))))

(use-package lsp-mode
  :commands lsp
  :custom
  (lsp-completion-provider :none)
  (lsp-clients-typescript-server-args '("--stdio" "--tsserver-log-file" "/dev/stderr"))
  :config
  (defvar lsp-file-watch-ignored-directories-additional nil
    "Additional ignored directories added to lsp-file-watch-ignored-directories.")
  (put 'lsp-file-watch-ignored-directories-additional 'safe-local-variable #'lsp--string-listp)
  (add-function :around (symbol-function 'lsp-file-watch-ignored-directories)
                (lambda (orig)
                  (print "appending")
                  (append lsp-file-watch-ignored-directories-additional (funcall orig))))
  (add-to-list 'lsp-file-watch-ignored-directories "/\\.docusaurus$")
  (add-to-list 'lsp-file-watch-ignored-directories "/\\.next$")
  (setq-default lsp-eslint-trace-server t)
  (setq-default lsp-enable-snippet nil)
  (setq-default lsp-modeline-code-actions-enable nil)
  (setq-default lsp-modeline-diagnostics-enable nil))

(use-package prettier :init (global-prettier-mode))

(use-package magit
  :config
  (add-hook 'git-commit-setup-hook 'git-commit-turn-on-auto-fill))

(use-package git-modes)

(use-package rustic
  :defer t
  :config
  (add-hook 'rust-mode-hook 'lsp)
  (setq-default
   lsp-rust-analyzer-proc-macro-enable t
   lsp-enable-symbol-highlighting nil
   rustic-format-on-save nil))

(use-package flycheck
  :custom (flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  :init (global-flycheck-mode))

(use-package sudo-edit :commands sudo-edit)

(use-package yaml-mode :mode "\\.\\(yaml\\|yml\\)$")

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-echo-documentation t)
  :init (global-corfu-mode))

(use-package popup)

(use-package nginx-mode)

(use-package dockerfile-mode :mode "^Dockerfile")

(use-package php-mode :mode "\\.\\(php\\|inc\\)$")

(use-package csharp-mode :mode "\\.cs$")

(use-package lua-mode :mode "\\.lua$")

(use-package glsl-mode :mode "\\.\\(glsl\\|vert\\|frag\\)$")

(use-package markdown-mode
  :mode (("\\.md$" . markdown-mode)
         ("README\\.md$" . gfm-mode)))

(use-package web-mode
  :mode "\\.html$"
  :config
  (add-hook 'web-mode-hook 'lsp)
  (setq-default
   web-mode-code-indent-offset 2
   web-mode-markup-indent-offset 2
   web-mode-css-indent-offset 2
   web-mode-ac-sources-alist
   '(("css" . (ac-source-css-property))
     ("html" . (ac-source-words-in-buffer ac-source-abbrev)))))

(use-package json-mode
  :mode "\\.json$"
  :config
  (add-hook 'json-mode-hook 'lsp)
  ;; disable json-jsonlist checking for json files
  (setq-default
   flycheck-disabled-checkers (append flycheck-disabled-checkers '(json-jsonlist))))

(use-package handlebars-mode :mode "\\.hbs$")

(use-package ssh-config-mode
  :mode ((".ssh/config\\'" . ssh-config-mode)
         ("sshd?_config\\'" . ssh-config-mode)
         ("known_hosts\\'" . ssh-known-hosts-mode)
         ("authorized_keys2?\\'" . ssh-authorized-keys-mode))
  :config
  (add-hook 'ssh-config-mode-hook 'turn-on-font-lock))

(use-package sql-indent
  :hook sql-mode)
