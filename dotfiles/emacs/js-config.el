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

;; Misc Coding

(show-paren-mode 1)
(electric-pair-mode 1)
(column-number-mode 1)


;; Haskell

(intero-global-mode 1)

;; GNU Global

(add-hook 'c-mode-hook 'ggtags-mode)
(add-hook 'c++-mode-hook 'ggtags-mode)

;; Tramp

;; Tramp has problems dealing with zsh, so just don't use it for Tramp
;; sessions.
(eval-after-load 'tramp '(setenv "SHELL" "/bin/bash"))
