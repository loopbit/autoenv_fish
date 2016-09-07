## setup
source activate.fish

if [ -z "$TMPDIR" ]
    set TMPDIR "/tmp"
end
set self_PID %self
set test_dir "$TMPDIR/_autoenv_$self_PID"

mkdir -p "$test_dir/a/b"
echo "echo -a/b-" > "$test_dir/a/b/.env"
echo "echo -a-" > "$test_dir/a/.env"
mkdir -p "$test_dir/c/d"
echo "echo -c/d-" > "$test_dir/c/d/.env"

cd $test_dir

## test
cd a # match=/-a-/ ; match!=/-a/b-/ ; status=0
cd ..
cd a/b # match=/-a-\n-a/b-/ ; status=0
cd ../..
cd c # match=/$^/ ; status=0
cd ..
cd c/d # match!=/-c-/ ; match=/-c/d-/ ; status=0
cd ../..
cd e # match!=/^$/ ; status!=0

## teardown
rm -rf "$test_dir"
