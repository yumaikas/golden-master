(import spork/path :as "path")
(import err)
(import tempfiles :as temp)

# task[Add an :html diff viewer to this based on frames/osprey/browsers]
(var *dir* "")

(defn set-dir [& dirs] 
  (def dive @[])
  # Ensuring that the directory exists, and is a directory
  (each d dirs
    (array/concat dive d)
    (match (os/stat (path/join ;dive))
      {:mode :directory} nil
      nil (os/mkdir (path/join ;dive))
      _ (err/str "Path " (path/join ;dive) " already exists, and is not a directory.")))
  (set *dir* (path/join ;dive)))

(defn- show-diff [expected-path actual] 
  # TODO: Find a diff tool to use here.
  (def [t/path f] (temp/open-file (temp/random-name)))
  (defer (os/rm t/path)
    (defer (:close f) (:write f actual))

    (print "")
    (def diff-proc (os/spawn ["diff" "-u" t/path expected-path] :p))
    (:wait diff-proc))
  (print ""))

(defn- interactive-accept-changes [name expected-path actual] 
  (when (= (os/getenv "GOLDEN_MASTER") "nointeract")
    (break false))

  (var retval false)
  (prompt :done
  (forever 
    (print (string name " has hanged. Do you want to:"))
    (print "  (a)ccept the changes?")
    (print "  (v)iew the changes?")
    (print "  (r)eject the changes?")
    (prin  "  (your choice): ")
    (def input (:read stdin :line))
    (match (string/from-bytes (input 0))
      "a" (do (spit expected-path actual) (set retval true) (return :done))
      "v" (show-diff expected-path actual)
      "r" (return :done))))
  retval)

(defn compare-text-files [name expected-path actual] 
  (when (= (os/stat expected-path) nil)
    (spit expected-path actual)
    (break true))
  (def expected (string (slurp expected-path)))
  (or (= expected actual) (interactive-accept-changes name expected-path actual)))

(defn compare 
  "Compare output with the previously recored output."
  [my/type name expected-path actual]
  (match my/type 
    :text (compare-text-files name (path/join *dir* expected-path) actual)
    _ (err/str "Acceptance doesn't know how to compare contents of type " my/type)))
