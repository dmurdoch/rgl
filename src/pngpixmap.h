#include "lib.hpp"
#include "types.h"
#include <png.h>

// C++ header file
// This file is part of RGL
//
// $Id$

class PNGPixmapFormat : public PixmapFormat {
public:
  PNGPixmapFormat()
  {
  }

  bool checkSignature(FILE* fd)
  {
    unsigned char buf[8];

    fread(buf, 1, 8, fd);
    fseek(fd, 0, SEEK_SET);

    return !png_sig_cmp(buf, 0, 8);
  }

  bool load(FILE* fd, Pixmap* pixmap)
  {
    Load load(fd, pixmap);

    if (load.init()) {
      bool success;
      success = load.process();
      if (!success)
        lib::printMessage("pixmap png loader: process failed");
      return success;
    } else {
      lib::printMessage("pixmap png loader: init failed");
      return false;
    }
  }

  bool save(FILE* fd, Pixmap* pixmap)
  {
    Save save(fd, pixmap);

    if (save.init())
      return save.process();
    else
      return false;
  }

private:

  //
  // CLASS
  //   Load
  //

  class Load {
  public:

    Load(FILE* _file, Pixmap* _pixmap)
    {
      file     = _file;
      pixmap   = _pixmap;
      png_ptr  = NULL;
      info_ptr = NULL;
      finish   = false;
      error    = false;
    }

    bool init(void) 
    {
      bool success = false;

      png_ptr = png_create_read_struct (PNG_LIBPNG_VER_STRING, (png_voidp)this, error_callback, warning_callback);

      if (png_ptr) {
        info_ptr = png_create_info_struct(png_ptr);
        if (info_ptr) {
          png_set_progressive_read_fn(png_ptr, (void *)this, info_callback, row_callback, end_callback);
          success = true;
        } 
      } 
      
      return success;
    }

    bool process()
    {
      while ((!feof(file)) && (!error)) {
        int size = fread(buffer,1,sizeof(buffer),file);
        if (ferror(file)) {
          printError("file read error");
          return false;
        }
        png_process_data(png_ptr, info_ptr, buffer, size);
      }

      return finish;
    }

    ~Load() 
    {
      if (png_ptr)
        png_destroy_read_struct(&png_ptr, (info_ptr) ? &info_ptr : NULL, (png_infopp)NULL);
    }

  private:

    static void printError(const char* error_msg) {
      char buf[256];
      sprintf(buf, "PNG Pixmap Loader Error: %s", error_msg);
      lib::printMessage(buf);
    }

    static void printWarning(const char* warning_msg) {
      char buf[256];
      sprintf(buf, "PNG Pixmap Loader Warning: %s", warning_msg);
      lib::printMessage(buf);
    }


    static void error_callback(png_structp png_ptr, png_const_charp error_msg) {

//      Load* load = (Load*) png_get_error_ptr(png_ptr);
      printError( (const char*) error_msg );

    }

    static void warning_callback(png_structp png_ptr, png_const_charp warning_msg) {

//      Load* load = (Load*) png_get_error_ptr(png_ptr);
      printWarning( (const char*) warning_msg );

    }


    static void info_callback(png_structp png_ptr, png_infop info) 
    {
      char buffer[256];
      Load* load = (Load*) png_get_progressive_ptr(png_ptr);

      png_uint_32 width, height;
      int  bit_depth, color_type, interlace_type, compression_type, filter_type;

      png_get_IHDR(load->png_ptr, load->info_ptr, &width, &height,
       &bit_depth, &color_type, &interlace_type,
       &compression_type, &filter_type);


      char* color_type_name;

      switch(color_type) {
        case PNG_COLOR_TYPE_RGB:
          color_type_name = (char*)"RGB";
          break;
        case PNG_COLOR_TYPE_GRAY:
          color_type_name = (char*)"GRAY";
          break;
        case PNG_COLOR_TYPE_PALETTE:
          color_type_name = (char*)"INDEX";
          break;
        case PNG_COLOR_TYPE_RGB_ALPHA:
          color_type_name = (char*)"RGBALPHA";
          break;
        case PNG_COLOR_TYPE_GRAY_ALPHA:
          color_type_name = (char*)"GRAYALPHA";
          break;
        default:
          color_type_name = (char*)"unknown";
          break;
      };

      const char* interlace_string = (interlace_type == PNG_INTERLACE_ADAM7) ? "adam7 interlace " : "";

      if (bit_depth == 16)
        png_set_strip_16(png_ptr);
      else if (bit_depth < 8  && color_type == PNG_COLOR_TYPE_GRAY)
        png_set_expand_gray_1_2_4_to_8(png_ptr);
      else if (bit_depth != 8)  /* this should never happen with current formats... */
        goto unsupported;
      
      if (interlace_type == PNG_INTERLACE_ADAM7)
        goto unsupported;

      PixmapTypeID typeID;

      switch(color_type) {
        case PNG_COLOR_TYPE_RGB:
          typeID = RGB24;
          goto init;
        case PNG_COLOR_TYPE_GRAY:
          typeID = GRAY8;
          goto init;
        case PNG_COLOR_TYPE_RGB_ALPHA:
          typeID = RGBA32;
          goto init;        
        case PNG_COLOR_TYPE_PALETTE:
          png_set_palette_to_rgb(png_ptr);
          typeID = RGB24;
          goto init;
        case PNG_COLOR_TYPE_GRAY_ALPHA:
          png_set_gray_to_rgb(png_ptr);
          typeID = RGBA32;
          goto init;
        default:
          goto unsupported;
          break;
      };

init:
      if (typeID == RGB24 && png_get_valid(png_ptr, info, PNG_INFO_tRNS)) {
        png_set_tRNS_to_alpha(png_ptr);
        typeID = RGBA32;
      }
      
      load->pixmap->init(typeID, width,height,bit_depth);

      png_read_update_info(load->png_ptr,load->info_ptr);
      return;

unsupported:
      sprintf(buffer,"%s%s format unsupported: %lux%lu (%d bits per channel)", 
              interlace_string, color_type_name, 
              (long unsigned int)width, (long unsigned int)height, bit_depth);
      lib::printMessage(buffer);
      load->error = true;
      png_read_update_info(load->png_ptr,load->info_ptr);
      return;


      /* Do any setup here, including setting any of
         the transformations mentioned in the Reading
         PNG files section.  For now, you _must_ call
         either png_start_read_image() or
         png_read_update_info() after all the
         transformations are set (even if you don't set
         any).  You may start getting rows before
         png_process_data() returns, so this is your
         last chance to prepare for that.
       */
    }
    static void row_callback(png_structp png_ptr, png_bytep new_row, png_uint_32 row_num, int pass)
    {
      Load* load = (Load*) png_get_progressive_ptr(png_ptr);

      void* rowptr = load->pixmap->data + load->pixmap->bytesperrow * (load->pixmap->height-1-row_num);

      memcpy(rowptr, new_row, load->pixmap->bytesperrow);
    }

    static void end_callback(png_structp png_ptr, png_infop info)
    {
      Load* load = (Load*) png_get_progressive_ptr(png_ptr);

      load->finish = true;
    /* This function is called after the whole image
       has been read, including any chunks after the
       image (up to and including the IEND).  You
       will usually have the same info chunk as you
       had in the header, although some data may have
       been added to the comments and time fields.

       Most people won't do much here, perhaps setting
       a flag that marks the image as finished.
     */
    }

/*
    static void end_callback(void) {
  }
 */

    typedef void (PNGAPI *png_error_ptr) PNGARG((png_structp, png_const_charp));

    FILE* file;
    Pixmap* pixmap;

    png_structp png_ptr;
    png_infop info_ptr;
    int bufsize;
    unsigned char buffer[4096];
    bool error;
    bool finish;

    int width;
    int height;
    int bit_depth;


  };


  //
  // CLASS
  //   Save
  //

  class Save {
  public:
    Save(FILE* in_file, Pixmap* in_pixmap)
    {
      file     = in_file;
      pixmap   = in_pixmap;
      png_ptr  = NULL;
      info_ptr = NULL;
    }

    bool init(void)
    {
      bool success = false;

      png_ptr = png_create_write_struct (PNG_LIBPNG_VER_STRING, (png_voidp)this, error_callback, warning_callback);
      
      if (png_ptr) {
        info_ptr = png_create_info_struct(png_ptr);
        if (info_ptr) {
          png_init_io(png_ptr, file);
          success = true;
        }
      }

      return success;
    }

    bool process(void)
    {
      if (setjmp(png_jmpbuf(png_ptr))) {
        printError("an error occured");
        png_destroy_write_struct(&png_ptr, &info_ptr);
        return false;
      }

      png_set_filter(png_ptr, 0, PNG_FILTER_NONE);

      
      const int color_type = PNG_COLOR_TYPE_RGB;
      const int interlace_type = PNG_INTERLACE_NONE;
      const int compression_type = PNG_COMPRESSION_TYPE_DEFAULT;
      const int filter_type = PNG_FILTER_TYPE_DEFAULT;

      png_set_IHDR(png_ptr, info_ptr, 
        pixmap->width, 
        pixmap->height, pixmap->bits_per_channel, 
        color_type, interlace_type, compression_type, filter_type);

      png_text text[1];

      text[0].key  = (png_charp)"Software";
      text[0].text = (png_charp)"R/RGL package/libpng";
      text[0].compression = PNG_TEXT_COMPRESSION_NONE;

      png_set_text(png_ptr, info_ptr, text, sizeof(text)/sizeof(png_text) );
      
      png_write_info(png_ptr, info_ptr);

      png_bytep rowptr = (png_bytep) ( ((u8*)pixmap->data) + (pixmap->height - 1) * pixmap->bytesperrow );

      for(unsigned int i=0;i<pixmap->height;i++) {
        png_write_row(png_ptr, rowptr);
        rowptr -= pixmap->bytesperrow;
      }

      png_write_end(png_ptr, info_ptr);

      return true;
    }

    ~Save()
    {
      if (png_ptr)
        png_destroy_write_struct(&png_ptr, (info_ptr) ? &info_ptr : NULL);

    }

  private:

    static void printError(const char* error_msg) {
      char buf[256];
      sprintf(buf, "PNG Pixmap Saver Error: %s", error_msg);
      lib::printMessage(buf);
    }

    static void printWarning(const char* warning_msg) {
      char buf[256];
      sprintf(buf, "PNG Pixmap Saver Warning: %s", warning_msg);
      lib::printMessage(buf);
    }


    static void error_callback(png_structp png_ptr, png_const_charp error_msg) {

//      Save* save = (Save*) png_get_error_ptr(png_ptr);
      printError( (const char*) error_msg );

    }

    static void warning_callback(png_structp png_ptr, png_const_charp warning_msg) {

//      Save* save = (Save*) png_get_error_ptr(png_ptr);
      printWarning( (const char*) warning_msg );

    }


    FILE* file;
    Pixmap* pixmap;

    png_structp png_ptr;
    png_infop info_ptr;

  };

};

