/* protobuf config.h for MSVC.  On other platforms, this is generated
 * automatically by autoheader / autoconf / configure. */

/* the location of <hash_map> */
#define HASH_SET_H <tr1/unordered_set>
//#define HASH_MAP_H <hash_map>

/* define if the compiler has hash_map */
#define HAVE_HASH_MAP 1

/* define if the compiler has hash_set */
#define HAVE_HASH_SET 1



#define HASH_MAP_CLASS unordered_map
#define HASH_MAP_H <tr1/unordered_map>
#define HASH_NAMESPACE std::tr1
#define HASH_SET_CLASS unordered_set


#define QT_SHAREDPOINTER_TRACK_POINTERS
