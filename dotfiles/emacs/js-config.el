;; Style

(menu-bar-mode -1)
(tool-bar-mode -1)

(when (display-graphic-p)
    (invert-face 'default)
    (scroll-bar-mode -1))

;; Write all temporary files somewhere else
;;
;; https://www.gnu.org/software/emacs/manual/html_node/efaq/Not-writing-files-to-the-current-directory.html
(setq lock-file-name-transforms
      '(("\\`/.*/\\([^/]+\\)\\'" "~/.emacs.d/aux/\\1" t)))
(setq auto-save-file-name-transforms
      '(("\\`/.*/\\([^/]+\\)\\'" "~/.emacs.d/aux/\\1" t)))
(setq backup-directory-alist
      '((".*" . "~/.emacs.d/aux/")))

;; MELPA

(require 'package)
(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)

;; Flycheck

(with-eval-after-load 'flycheck
  (add-hook 'flycheck-mode-hook #'flycheck-inline-mode)
  ;(flycheck-pos-tip-mode)
  (flycheck-grammarly-setup))

;; Misc Coding

(show-paren-mode 1)
(electric-pair-mode 1)
(column-number-mode 1)
(editorconfig-mode 1)

;; Direnv

;(direnv-mode 1)

;; Haskell

(require 'lsp)
(require 'lsp-ui)
(require 'lsp-nix)

(add-hook 'nix-mode-hook #'lsp-deferred)
(add-hook 'c-mode-common-hook #'lsp-deferred)

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
 '(inhibit-startup-screen t)
 '(lsp-haskell-process-args-hie nil)
 '(lsp-haskell-process-path-hie "haskell-language-server-wrapper")
 '(lsp-nix-nil-formatter ["nixpkgs-fmt"])
 '(make-backup-files nil)
 '(nix-nixfmt-bin "nixpkgs-fmt")
 '(ring-bell-function 'ignore)
 '(rustic-analyzer-command '("/home/julian/.cargo/bin/rust-analyzer"))
 '(rustic-format-trigger 'on-save)
 '(safe-local-variable-values '((dante-methods stack))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
