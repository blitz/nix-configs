;; Style

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(if (display-graphic-p)
    (invert-face 'default))

;; MELPA

(require 'package)
(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)

;; Misc Coding

(show-paren-mode 1)
(electric-pair-mode 1)
(column-number-mode 1)

;; Direnv

(direnv-mode 1)

;; Haskell

(require 'lsp)
(require 'lsp-haskell)

;; Hooks so haskell and literate haskell major modes trigger LSP setup
(add-hook 'haskell-mode-hook #'lsp)
(add-hook 'haskell-literate-mode-hook #'lsp)

;; (require 'haskell-interactive-mode)
;; (require 'haskell-process)
;; (add-hook 'haskell-mode-hook 'interactive-haskell-mode)

;; GNU Global

(add-hook 'c-mode-hook 'ggtags-mode)
(add-hook 'c++-mode-hook 'ggtags-mode)

;; Tramp

;; Tramp has problems dealing with zsh, so just don't use it for Tramp
;; sessions.
(eval-after-load 'tramp '(setenv "SHELL" "/bin/bash"))

;; Customize

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dante-tap-type-time 5)
 '(haskell-stylish-on-save t)
 '(lsp-haskell-process-args-hie nil)
 '(lsp-haskell-process-path-hie "ghcide")
 '(make-backup-files nil)
 '(safe-local-variable-values '((dante-methods stack))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
