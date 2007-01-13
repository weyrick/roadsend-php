;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler Runtime Libraries
;; Copyright (C) 2007 Roadsend, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation; either version 2.1
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.
;; 
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; ***** END LICENSE BLOCK *****

(module php-image-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   (library php-runtime)
   (import (php-files-lib "php-files.scm"))
   (export
    (init-php-image-lib)
    (image_type_to_mime_type image_type)
    (getimagesize filename imageinfo)))

(define (init-php-image-lib)
   1)


(defconstant IMAGETYPE_GIF (int->onum 1))
(defconstant IMAGETYPE_JPEG (int->onum 2))
(defconstant IMAGETYPE_PNG (int->onum 3))
(defconstant IMAGETYPE_SWF (int->onum 4))
(defconstant IMAGETYPE_PSD (int->onum 5))
(defconstant IMAGETYPE_BMP (int->onum 6))
(defconstant IMAGETYPE_TIFF_II (int->onum 7))
(defconstant IMAGETYPE_TIFF_MM (int->onum 8))
(defconstant IMAGETYPE_JPC (int->onum 9))
;; jpeg2000 is intentionally the same as jpc
(defconstant IMAGETYPE_JPEG2000 (int->onum 9))
(defconstant IMAGETYPE_JP2 (int->onum 10))
(defconstant IMAGETYPE_JPX (int->onum 11))
(defconstant IMAGETYPE_JB2 (int->onum 12))
(defconstant IMAGETYPE_SWC (int->onum 13))
(defconstant IMAGETYPE_IFF (int->onum 14))
(defconstant IMAGETYPE_WBMP (int->onum 15))
(defconstant IMAGETYPE_XBM (int->onum 16))

(defbuiltin (image_type_to_mime_type image_type)
   (set! image_type (convert-to-integer image_type))
   (cond
      ((php-= image_type IMAGETYPE_GIF) "image/gif")
      ((php-= image_type IMAGETYPE_JPEG) "image/jpeg")
      ((php-= image_type IMAGETYPE_PNG) "image/png")
      ((or (php-= image_type IMAGETYPE_SWF)
           (php-= image_type IMAGETYPE_SWC))
       "application/x-shockwave-flash")
      ((php-= image_type IMAGETYPE_PSD) "image/psd")
      ((php-= image_type IMAGETYPE_BMP) "image/bmp")
      ((or (php-= image_type IMAGETYPE_TIFF_II) 
           (php-= image_type IMAGETYPE_TIFF_MM))
       "image/tiff")
      ((php-= image_type IMAGETYPE_IFF) "image/iff")
      ((php-= image_type IMAGETYPE_WBMP) "image/vnd.wap.wbmp")
      ((php-= image_type IMAGETYPE_JPC) "application/octet-stream")
      ((php-= image_type IMAGETYPE_JP2) "image/jp2")
      ((php-= image_type IMAGETYPE_XBM) "image/xbm")
      (else "application/octet-stream")))

(define +gif-magic+ "GIF")
(define +jpg-magic+ "\xff\xd8\xff")
(define +png-magic+ "\x89PNG\x0d\x0a\x1a\x0a")


(defbuiltin (getimagesize filename ((ref . imageinfo) 'unset))
   (bind-exit (return)
      (let ((stream #f))
         (unwind-protect
            (begin
               (set! stream (php-funcall 'fopen filename "rb"))
               (unless stream (return FALSE))
               (let ((buf (php-funcall 'fread stream 1024)))
                  (unless buf (return (php-warning "Read error!")))
                  (multiple-value-bind (width height type bits channels)
                     (cond
                        ((substring-at? buf +gif-magic+ 0)
                         (read-gif-dimensions stream buf))
                        ((substring-at? buf +jpg-magic+ 0)
                         ;; XXX we don't support reading the jpg APP markers for the info parameter
                         (read-jpeg-dimensions stream buf))
                        ((substring-at? buf +png-magic+ 0)
                         (read-png-dimensions stream buf))
                        (else (return FALSE)))
                     (let ((retval (list->php-hash
                                    (list (int->onum width) (int->onum height) type
                                          (mkstr "width=\"" width "\" height=\"" height "\"")))))
                        (unless (zero? bits)
                           (php-hash-insert! retval "bits" (int->onum bits)))
                        (unless (zero? channels)
                           (php-hash-insert! retval "channels" (int->onum channels)))
                        (php-hash-insert! retval "mime"
                                          (php-funcall 'image_type_to_mime_type type))
                        retval))))
            (when stream
               (php-funcall 'fclose stream))))))

(define (read-gif-dimensions stream buf)
   (if (< (string-length buf) 11)
       (begin
          (php-warning "Read error!")
          (values 0 0 IMAGETYPE_GIF 0 0))
       (let* ((width (bit-or (char->integer (string-ref buf 6))
                             (bit-lsh (char->integer (string-ref buf 7)) 8)))
              (height (bit-or (char->integer (string-ref buf 8))
                              (bit-lsh (char->integer (string-ref buf 9)) 8)))
              (bits (if (zero? (bit-and (char->integer (string-ref buf 10)) #x80))
                        (+ 1   (bit-and (char->integer (string-ref buf 10)) #x07))
                        0))
              (channels 3))
          (values width height IMAGETYPE_GIF bits channels))))

(define (read-png-dimensions stream buf)
   (if (< (string-length buf) 25)
       (begin
          (php-warning "Read error!")
          (values 0 0 IMAGETYPE_PNG 0 0))
       ;; Width:              4 bytes
       ;; Height:             4 bytes
       ;; Bit depth:          1 byte
       ;; Color type:         1 byte
       ;; Compression method: 1 byte
       ;; Filter method:      1 byte
       ;; Interlace method:   1 byte
       (let ((width (+ (bit-lsh (char->integer (string-ref buf 16)) 24)
                       (bit-lsh (char->integer (string-ref buf 17)) 16)
                       (bit-lsh (char->integer (string-ref buf 18)) 8)
                       (char->integer (string-ref buf 19))))
             (height (+ (bit-lsh (char->integer (string-ref buf 20)) 24)
                        (bit-lsh (char->integer (string-ref buf 21)) 16)
                        (bit-lsh (char->integer (string-ref buf 22)) 8)
                        (char->integer (string-ref buf 23))))
             (bits (char->integer (string-ref buf 24))))
          (values width height IMAGETYPE_PNG bits 0))))

(define (read-jpeg-dimensions stream buf)
   (bind-exit (return)
      ;; we maintain our own hokey buffer because the php fgetc will
      ;; return "c" instead of #\c... our streams stuff really needs
      ;; work.
      (let* ((pos 0)             
             (fail (lambda (msg)
                      (php-warning msg)
                      (return (values 0 0 IMAGETYPE_JPEG 0 0))))
             (read-byte
              (lambda ()
                 (when (>= pos (string-length buf))
                    (set! pos 0)
                    (set! buf (php-funcall 'fread stream 1024))
                    (unless (convert-to-boolean buf) (fail "Read error!")))
                 (begin0
                  (char->integer (string-ref buf pos))
                  (set! pos (+ pos 1)))))
             (seek-cur
              (lambda (amt)
                 (if (> (string-length buf) (+ pos amt))
                     (set! pos (+ pos amt))
                     (let ((seek-retval 
                            (php-funcall 'fseek stream
                                         (- amt (- (string-length buf) pos))
                                         SEEK_CUR)))
                        (cond
                           ((php-= seek-retval *zero*) (set! buf ""))
                           ;; remote stream
                           ((not seek-retval) (dotimes (i amt) (read-byte)))
                           ;; seek error
                           (else (fail "Seek error!")))))))
             (read-2
              (lambda ()
                 (+ (bit-lsh (read-byte) 8) (read-byte)))))
         ;; this is the actual jpeg reading code
         (let loop ((marker (read-byte)))
            (when (= marker #xFF)
               ;; I haven't found any reference to this, but it seems
               ;; as though a marker is preceded by one _or more_ #xFF
               ;; bytes, so snarf them:
               (let liip ()
                  (when (= marker #xFF)
                     (set! marker (read-byte))
                     (liip)))
               (cond
                  ((member marker '(#xC0 #xC1 #xC2)) ; SOF markers
                   (let ((length (read-2))
                         (bits (read-byte))
                         (height (read-2))
                         (width (read-2))
                         (channels (read-byte)))
                      (return (values width height IMAGETYPE_JPEG bits channels))))
                  ((member marker '(#xC3 #xC5 #xC6 #xC7 #xC8 #xC9 #xCA #xCB #xCD #xCE #xCF))
                   ;; mystery to me
                   (fail "Unsupported JPEG format"))
                  ((not (member marker '(#xD0 #xD1 #xD2 #xD3 #xD4 #xD5 #xD6 #xD7 #xD8 #x01))) ; no param markers
                   (let ((len (read-2)))
                      (unless (< len 2)
                         (seek-cur (- len 2)))))))
            (loop (read-byte))))))
                   



