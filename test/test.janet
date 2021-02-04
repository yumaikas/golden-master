(use testament)
(import ../golden-master :as "gold")

(gold/set-dir "test" "records")

(defsuite!
  (deftest master-test
    (assert-equal true (gold/compare :text "test1" "test1.txt" "This is a test!\nWith more changes!\nMore lines\n more testing\n\na print farm\n"))))



