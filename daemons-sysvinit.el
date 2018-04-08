;;; daemons-sysvinit.el --- UI for managing init system daemons (services) -*- lexical-binding: t -*-

;; Copyright (c) 2018 Chris Bowdon
;;
;; Author: Chris Bowdon
;; URL: https://github.com/cbowdon/daemons.el
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3
;;
;; Created: February 13, 2018
;; Modified: February 13, 2018
;; Version: 1.2.0
;; Keywords: unix convenience
;; Package-Requires: ((emacs "25"))
;;
;;; Commentary:
;; This file provides SysVinit support for daemons.el.

;;; Code:
(require 'seq)
(require 'daemons)

(defvar daemons-sysvinit--commands-alist
  '((status . (lambda (name) (format "service %s status" name)))
    (start . (lambda (name) (format "service %s start" name)))
    (stop . (lambda (name) (format "service %s stop" name)))
    (restart . (lambda (name) (format "service %s restart" name)))
    (reload . (lambda (name) (format "service %s reload" name))))
  "Daemons commands alist for SysVinit.")

(defun daemons-sysvinit--parse-list-item (raw-chkconfig-output)
  "Parse a single line from RAW-CHKCONFIG-OUTPUT into a tabulated list item."
  (let* ((parts (split-string raw-chkconfig-output nil t))
         (name (car parts))
         (run-level-statuses (cdr parts)))
    (list name (apply 'vector (cons name run-level-statuses)))))

(defun daemons-sysvinit--list ()
  "Return a list of daemons on a SysVinit system."
  (thread-last "chkconfig --list"
    (daemons--shell-command-to-string)
    (daemons--split-lines)
    (seq-map 'daemons-sysvinit--parse-list-item)))

(defun daemons-sysvinit--list-headers ()
  "Return the list of headers for a SysVinit ‘daemons-mode’ buffer."
  (apply 'vector
         (cons '("Daemon (service)" 40 t)
               (seq-map
                (lambda (x)
                  (list (number-to-string x) 5 t))
                (number-sequence 0 6)))))

(setq daemons--commands-alist daemons-sysvinit--commands-alist
      daemons--list-fun 'daemons-sysvinit--list
      daemons--list-headers-fun 'daemons-sysvinit--list-headers)

(provide 'daemons-sysvinit)
;;; daemons-sysvinit.el ends here
