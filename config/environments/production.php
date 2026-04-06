<?php

use Roots\WPConfig\Config;
use function Env\env;

// AS3CF_SETTINGS must be a serialized string - the plugin calls maybe_unserialize() on this constant.
// use-server-roles: set to true if the host has an IAM instance profile with S3 permissions,
// and remove access-key-id / secret-access-key. Otherwise populate AWS_ACCESS_KEY_ID and
// AWS_SECRET_ACCESS_KEY in the environment with a key scoped to only this bucket.
Config::define('AS3CF_SETTINGS', serialize([
    'provider'          => 'aws',
    'access-key-id'     => env('AWS_ACCESS_KEY_ID'),
    'secret-access-key' => env('AWS_SECRET_ACCESS_KEY'),
    'bucket'            => env('AWS_BUCKET'),
    'region'            => env('AWS_REGION') ?: 'us-east-1',
    'copy-to-s3'        => true,
    'serve-from-s3'     => true,
    'remove-local-file' => true,
]));