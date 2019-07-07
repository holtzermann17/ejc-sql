;;; ejc-eldoc.el -- ejc-sql eldoc support (the part of ejc-sql).

;;; Copyright (C) 2019 - Kostafey <kostafey@gmail.com>

;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software Foundation,
;;; Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.  */

;;; Code:

(require 'dash)
(require 'eldoc)
(require 'ejc-lib)

(defun ejc-replace-property-mark (text fmt face)
  (while (string-match fmt text)
    (let ((beg (match-beginning 0))
          (end (match-end 0)))
      (setq text (concat (substring text 0 beg)
                         (substring text (1+ beg))))
      (add-face-text-property beg (1- end) face t text)))
  text)

(defun ejc-propertize (text)
  (-> text
      (ejc-replace-property-mark "\\%\\w+"
                                 'font-lock-keyword-face)
      (ejc-replace-property-mark "\\#\\w+"
                                 'eldoc-highlight-function-argument)))

(defconst ejc-sql-expressions
  (list
   "SELECT"
   "%SELECT #field... %FROM table [%WHERE predicate]"
   "FROM"
   "%SELECT field... %FROM #table [%WHERE predicate]"
   "WHERE"
   "%WHERE #predicate [%OR predicate] [%AND predicate]"))

(defun ejc-eldoc-function ()
  "Returns a doc string appropriate for the current context, or nil."
  (let ((word (trim-string (ejc-get-word-at-point (point)))))
    (if-let ((sql-expression (lax-plist-get ejc-sql-expressions word)))
        (ejc-propertize sql-expression))))

;;;###autoload
(defun ejc-eldoc-setup ()
  "Set up eldoc function and enable eldoc-mode."
  (interactive)
  (setq-local eldoc-documentation-function #'ejc-eldoc-function)
  (eldoc-mode +1))

(provide 'ejc-eldoc)

;;; ejc-eldoc.el ends here