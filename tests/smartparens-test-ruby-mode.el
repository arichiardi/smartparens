(require 'smartparens-test-env)
(require 'smartparens-ruby)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; basic pairs

(defun sp-ruby-test-slurp-assert (n in _ expected)
  (with-temp-buffer
    (ruby-mode)
    (smartparens-mode +1)
    (save-excursion
      (insert in))
    (goto-char (search-forward (regexp-quote "X")))
    (delete-char -1)
    (sp-forward-slurp-sexp n)
    (delete-trailing-whitespace)
    (should (equal (buffer-string) expected))))

(ert-deftest sp-test-ruby-slurp-forward ()
  (sp-ruby-test-slurp-assert 1 "
if teXst
end
foo
" :=> "
if test
  foo
end
")

  (sp-ruby-test-slurp-assert 1 "
if teXst
end
if test2
  foo
end
" :=> "
if test
  if test2
    foo
  end
end
")

  (sp-ruby-test-slurp-assert 1 "
if teXst
end
foo.bar
" :=> "
if test
  foo
end.bar
")

  (sp-ruby-test-slurp-assert 2 "
if teXst
end
foo.bar
" :=> "
if test
  foo.bar
end
")

  (sp-ruby-test-slurp-assert 5 "
beginX
end
test(1).test[2].test
" :=> "
begin
  test(1).test[2].test
end
")

  (sp-ruby-test-slurp-assert 5 "
beginX
end
test ? a : b
" :=> "
begin
  test ? a : b
end
")

  (sp-ruby-test-slurp-assert 1 "
beginX
end
Module::Class
" :=> "
begin
  Module::Class
end
")
  )

(ert-deftest sp-test-ruby-slurp-backward ()
  (sp-ruby-test-slurp-assert -2 "
foo.bar
begin X
end
" :=> "
begin
  foo.bar
end
")

  (sp-ruby-test-slurp-assert -1 "
if test
 foo.bar
end
begin X
end
" :=> "
begin
  if test
    foo.bar
  end
end
")

  (sp-ruby-test-slurp-assert -5 "
test(1).test[2].test
beginX
end
" :=> "
begin
  test(1).test[2].test
end
")

  (sp-ruby-test-slurp-assert -5 "
test ? a : b
beginX
end
" :=> "
begin
  test ? a : b
end
")

  (sp-ruby-test-slurp-assert -1 "
Module::Class
beginX
end
" :=> "
begin
  Module::Class
end
")

  )

(ert-deftest sp-test-ruby-slurp-with-inline-blocks ()
  (sp-ruby-test-slurp-assert 1 "
if teXst
end
foo if true
" :=> "
if test
  foo
end if true
")

  (sp-ruby-test-slurp-assert 2 "
if teXst
end
foo if true
" :=> "
if test
  foo if true
end
")

  (sp-ruby-test-slurp-assert 2 "
if teXst
end
foo = if true
        bar
      end
" :=> "
if test
  foo = if true
          bar
        end
end
")
  )

(defun sp-ruby-test-splice-assert (n in _ expected)
  (with-temp-buffer
    (ruby-mode)
    (smartparens-mode +1)
    (save-excursion
      (insert in))
    (goto-char (search-forward (regexp-quote "X")))
    (delete-char -1)
    (sp-splice-sexp n)
    (delete-trailing-whitespace)
    (should (equal (buffer-string) expected))))

(ert-deftest sp-test-ruby-splice ()
  (sp-ruby-test-splice-assert 1 "
if teXst
end
" :=> "
test
")

  (sp-ruby-test-splice-assert 1 "
if foo
  if baXr
  end
end
" :=> "
if foo
  bar
end
")

  (sp-ruby-test-splice-assert 1 "
if foo
  begin
    barX
  end
end
" :=> "
if foo
  bar
end
")

  (sp-ruby-test-splice-assert 1 "
if foo
  test if baXr
end
" :=> "
foo
test if bar
")

  ;; TODO: should not leave two spaces after splice
  (sp-ruby-test-splice-assert 1 "
if foo
  foo = if baXr
          v
        end
end
" :=> "
if foo
  foo =  bar
  v
end
")

  (sp-ruby-test-splice-assert 1 "
foo(ifX test; bar; end)
" :=> "
foo( test; bar; )
")

  )



(provide 'smartparens-test-ruby-mode)