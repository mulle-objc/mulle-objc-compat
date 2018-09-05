#include "property.h"


#include <assert.h>

/*
 * @property
 */


char   *property_copyAttributeValue( objc_property_t property, char *attributeName)
{
  
}

objc_property_attribute_t *property_copyAttributeList(objc_property_t prop, 
                                                      unsigned int *outCount)
{
    if (!prop) {
        if (outCount) *outCount = 0;
        return nil;
    }
}


//
// this is brazen theft of https://github.com/RetVal/objc-runtime/blob/1614b34b287a4a926ae6aa0c6e0e2e494c206599/runtime/objc-class.mm#L1085
//
/*
  Property attribute string format:
  - Comma-separated name-value pairs. 
  - Name and value may not contain ,
  - Name may not contain "
  - Value may be empty
  - Name is single char, value follows
  - OR Name is double-quoted string of 2+ chars, value follows
  Grammar:
    attribute-string: \0
    attribute-string: name-value-pair (',' name-value-pair)*
    name-value-pair:  unquoted-name optional-value
    name-value-pair:  quoted-name optional-value
    unquoted-name:    [^",]
    quoted-name:      '"' [^",]{2,} '"'
    optional-value:   [^,]*
*/
static unsigned int   iteratePropertyAttributes( char *attrs, 
                                                 BOOL (*fn)(unsigned int index, 
                                                            void *ctx1, void *ctx2, 
                                                            char *name, size_t nlen, 
                                                            char *value, size_t vlen), 
                                                 void *ctx1, void *ctx2)
{
   if( ! attrs) 
     return 0;

#ifndef NDEBUG
   char *attrsend = attrs + strlen(attrs);
#endif
   unsigned int attrcount = 0;

   while (*attrs) 
   {
      // Find the next comma-separated attribute
      char *start = attrs;
      char *end   = start + strcspn(attrs, ",");

      // Move attrs past this attribute and the comma (if any)
      attrs = *end ? end+1 : end;

      assert(attrs <= attrsend);
      assert(start <= attrsend);
      assert(end <= attrsend);
      
      // Skip empty attribute
      if (start == end) 
         continue;

      // Process one non-empty comma-free attribute [start,end)
      char *nameStart;
      char *nameEnd;

      assert( start < end);
      assert( *start);

      if( *start != '\"') 
      {
         // single-char short name
         nameStart = start;
         nameEnd   = start+1;
         start++;
      }
      else 
      {
         // double-quoted long name
         nameStart = start+1;
         nameEnd   = nameStart + strcspn(nameStart, "\",");
         start++;                       // leading quote
         start    += nameEnd - nameStart;  // name
         if (*start == '\"')  
            start++;   // trailing quote, if any
      }

      // Process one possibly-empty comma-free attribute value [start,end)
      char *valueStart;
      char *valueEnd;

      assert( start <= end);

      valueStart = start;
      valueEnd  = end;

      BOOL more = (*fn)(attrcount, ctx1, ctx2, 
                        nameStart, nameEnd-nameStart, 
                        valueStart, valueEnd-valueStart);
      attrcount++;

      if( ! more) 
         break;
   }

   return attrcount;
}

static BOOL 
findOneAttribute(unsigned int index, void *ctxa, void *ctxs, 
                 char *name, size_t nlen, char *value, size_t vlen)
{
    char *query = (char *)ctxa;
    char **resultp = (char **)ctxs;

    if (strlen(query) == nlen  &&  0 == strncmp(name, query, nlen)) {
        char *result = (char *)calloc(vlen+1, 1);
        memcpy(result, value, vlen);
        result[vlen] = '\0';
        *resultp = result;
        return NO;
    }

    return YES;
}


static BOOL   copyOneAttribute( unsigned int index, 
                                void *ctxa, 
                                void *ctxs, 
                                char *name, size_t nlen, 
                                char *value, size_t vlen)
{
   objc_property_attribute_t **ap = (objc_property_attribute_t**)ctxa;
   char **sp = (char **)ctxs;

   objc_property_attribute_t *a = *ap;
   char *s = *sp;

   a->name = s;
   memcpy(s, name, nlen);
   s += nlen;
   *s++ = '\0';

   a->value = s;
   memcpy(s, value, vlen);
   s += vlen;
   *s++ = '\0';

   a++;

   *ap = a;
   *sp = s;

   return YES;
}


//
// this is a brazen theft of https://github.com/RetVal/objc-runtime/blob/1614b34b287a4a926ae6aa0c6e0e2e494c206599/runtime/objc-class.mm
//
objc_property_attribute_t *copyPropertyAttributeList( char *attrs, unsigned int *outCount)
{
   if( ! attrs) 
   {
      if( outCount) 
         *outCount = 0;
      return nil;
   }

   // Result size:
   //   number of commas plus 1 for the attributes (upper bound)
   //   plus another attribute for the attribute array terminator
   //   plus strlen(attrs) for name/value string data (upper bound)
   //   plus count*2 for the name/value string terminators (upper bound)
   unsigned int attrcount = 1;
   char *s;

   for(s = attrs; s && *s; s++) 
   {
      if (*s == ',') 
      attrcount++;
   }

   size_t size = attrcount * sizeof(objc_property_attribute_t) + 
                 sizeof( objc_property_attribute_t) + 
                 strlen( attrs) + 
                 attrcount * 2;
   objc_property_attribute_t *result = (objc_property_attribute_t *) 
      mulle_calloc( size, 1);

   objc_property_attribute_t *ra = result;
   char *rs = (char *)(ra+attrcount+1);

   attrcount = iteratePropertyAttributes (attrs, copyOneAttribute, &ra, &rs);

   assert((uint8_t *)(ra+1) <= (uint8_t *) result + size);
   assert((uint8_t *)rs <= (uint8_t *) result + size);

   if (attrcount == 0) 
   {
      mulle_free( result);
      result = nil;
   }

   if (outCount) 
      *outCount = attrcount;
   return result;
}


char *copyPropertyAttributeValue( char *attrs, const char *name)
{
   char *result = nil;

   iteratePropertyAttributes(attrs, findOneAttribute, (void*)name, &result);

   return result;
}