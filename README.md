# golden-master

## Status

An golden-master testing library for Janet. Assumes that golden-master tests will be
interactive, but you can set `GOLDEN_MASTER=nointeract` to disable interactive requests to accept new outputs

## Usage

```janet
(use testament) # Currently uses 
(import golden-master :as "gold")

# Set the directory for acceptance tests to record their results to.
# Expects an `& args` list of path elements, 
# so as to be platform independent
(gold/set-dir "test" "records") 

(defsuite! 
  (deftest html-one
    (def to-compare "<html>This is some testing</html>")
    # Firest test always passes, the foll
    (assert-equal true (gold/compare :text "test1.html" to-compare))))

```

