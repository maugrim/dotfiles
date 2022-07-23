;;; -*- no-byte-compile: t; lexical-binding: t; -*-

;; Don't aggressively run GC
(setq gc-cons-threshold (* 256 1024 1024))

;; Disable package.el in favor of straight.el
(setq package-enable-at-startup nil)

;; UTF-8 everywhere by default
(set-language-environment "UTF-8")

;; set-language-enviornment sets default-input-method, which is unwanted
(setq default-input-method nil)

;; turn off mouse interface early in startup to avoid momentary display
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; set up visual frame defaults before any frame is created
(add-to-list 'default-frame-alist '(font . "Fira Code-11"))
(set-face-attribute 'mode-line nil :box nil)
(set-face-attribute 'mode-line-highlight nil :box nil)
(set-face-attribute 'mode-line-inactive nil :box nil)
(setq-default frame-title-format
              '(:eval
                (if (buffer-file-name)
                    (replace-regexp-in-string
                     (concat "/home/" user-login-name) "~" buffer-file-name)
                  "%b")))
