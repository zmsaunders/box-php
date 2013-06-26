php_version="$1"         # The full PHP version, like 5.4.15
php_version_alias="$2"   # The short alias, like 5.4

php_package_filename="php$php_version.tar.gz"
php_package_url="https://s3.amazonaws.com/box-assets/php/$php_package_filename"
php_version_dir="$PHP_BUILD_VERSIONS_DIR/$php_version_alias"

$status_code=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "$php_package_url")

if [ "$status_code" -eq "200" ]; then
  curl -O "$php_package_url"
  mkdir -p "$php_version_dir"

  tar -zxvf "$php_package_filename" -C "$php_version_dir"
else
  php-build -i development --pear "$php_version" "$php_version_dir"

  tar -zcvf "$php_package_filename" "$php_version_dir"

  secretKeyFile="$HOME/AWS_SECRET_KEY"
  echo "$AWS_SECRET_KEY" > secretKeyFile

  $AWS_ACCESS_KEY_ID
  $AWS_SECRET_KEY

  ./s3-put.sh -k "$AWS_ACCESS_KEY_ID" -s "$secretKeyFile" -c "application/x-tgz" -T "$php_package_filename" "/box-assets/php/$php_package_filename&x-amz-acl=public-read"
fi
