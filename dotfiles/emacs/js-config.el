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

(add-hook 'after-init-hook 'global-company-mode)
(setq company-minimum-prefix-length 1
      company-idle-delay 0.2)

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

;; Fuzzy File Opening

(use-package fzf
  :bind
    ;; Don't forget to set keybinds!
  :config
  (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        ;; command used for `fzf-grep-*` functions
        ;; example usage for ripgrep:
        ;; fzf/grep-command "rg --no-heading -nH"
        fzf/grep-command "grep -nrH"
        ;; If nil, the fzf buffer will appear at the top of the window
        fzf/position-bottom t
        fzf/window-height 15))

(keymap-global-set "C-f" 'fzf-git)

;; Grepping

(rg-enable-default-bindings)

;; Customize

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dante-tap-type-time 5)
 '(inhibit-startup-screen t)
 '(lsp-nix-nil-formatter ["nixpkgs-fmt"])
 '(make-backup-files nil)
 '(nix-nixfmt-bin "nixpkgs-fmt")
 '(ring-bell-function 'ignore)
 '(rustic-format-trigger 'on-save)
 '(safe-local-variable-values '((dante-methods stack))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
