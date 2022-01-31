other_dir=../../../Michael_MacKenzie/code/code_20220107/code_master/
for entry in `ls *.m`; do
    echo "=========================================="
    echo $entry
    echo "------------------------------------------"
    diff $entry $other_dir
done
