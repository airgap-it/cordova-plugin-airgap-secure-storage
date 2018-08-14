package ch.papers.securestorage

/**
 * Created by Dominik on 19.01.2018.
 */

object Constants {
    const val ANDROID_KEY_STORE = "AndroidKeyStore"
    const val SECURE_STORAGE_ALIAS = "secure_storage_"
    const val BASE_FILE_PATH = "secure_storage"
    const val KEY_SIZE = 256
    const val DIGEST_ALGORITHM = "SHA-256"

    const val FILESYSTEM_CIPHER_ALGORITHM = "AES/CBC/PKCS7Padding"
    const val PARANOIA_PASSPHRASE_CIPHER_ALGORITHM = "AES/CBC/PKCS7Padding"

    const val PBKDF2_ITERATIONS = 10000
    const val PBKDF2_OUTPUT_KEY_LENGTH = 256
    const val PBKDF2_ALGORITHM = "PBKDF2WithHmacSHA1"
    const val PARANOIA_KEY_FILE_NAME = "paranoia_key"
}