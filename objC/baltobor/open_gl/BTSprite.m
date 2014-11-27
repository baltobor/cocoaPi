//
//  BTSprite.m
//  Created by Jacek Wisniowski on 09.04.13.
//

#import "BTSprite.h"

#define MODE_CENTER 0
#define MODE_ORIGIN 1
#define MODE_RECT 2


/////////////////////////////
/******************** JPEG DECOMPRESSION SAMPLE INTERFACE *******************/

/* This half of the example shows how to read data from the JPEG decompressor.
 * It's a bit more refined than the above, in that we show:
 *   (a) how to modify the JPEG library's standard error-reporting behavior;
 *   (b) how to allocate workspace using the library's memory manager.
 *
 * Just to make this example a little different from the first one, we'll
 * assume that we do not intend to put the whole image into an in-memory
 * buffer, but to send it line-by-line someplace else.  We need a one-
 * scanline-high JSAMPLE array as a work buffer, and we will let the JPEG
 * memory manager allocate it for us.  This approach is actually quite useful
 * because we don't need to remember to deallocate the buffer separately: it
 * will go away automatically when the JPEG object is cleaned up.
 */


/*
 * ERROR HANDLING:
 *
 * The JPEG library's standard error handler (jerror.c) is divided into
 * several "methods" which you can override individually.  This lets you
 * adjust the behavior without duplicating a lot of code, which you might
 * have to update with each future release.
 *
 * Our example here shows how to override the "error_exit" method so that
 * control is returned to the library's caller when a fatal error occurs,
 * rather than calling exit() as the standard error_exit method does.
 *
 * We use C's setjmp/longjmp facility to return control.  This means that the
 * routine which calls the JPEG library must first execute a setjmp() call to
 * establish the return point.  We want the replacement error_exit to do a
 * longjmp().  But we need to make the setjmp buffer accessible to the
 * error_exit routine.  To do this, we make a private extension of the
 * standard JPEG error handler object.  (If we were using C++, we'd say we
 * were making a subclass of the regular error handler.)
 *
 * Here's the extended error handler struct:
 */

struct my_error_mgr {
  struct jpeg_error_mgr pub;	/* "public" fields */

  jmp_buf setjmp_buffer;	/* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

/*
 * Here's the routine that will replace the standard error_exit method:
 */

METHODDEF(void)
my_error_exit (j_common_ptr cinfo)
{
  /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
  my_error_ptr myerr = (my_error_ptr) cinfo->err;

  /* Always display the message. */
  /* We could postpone this until after returning, if we chose. */
  (*cinfo->err->output_message) (cinfo);

  /* Return control to the setjmp point */
  longjmp(myerr->setjmp_buffer, 1);
}


/*
 * Sample routine for JPEG decompression.  We assume that the source file name
 * is passed in.  We want to return 1 on success, 0 on error.
 */


GLOBAL(int)
read_JPEG_file (void *arg)
{
	
	BTSprite* sprite = (BTSprite*) arg;

	png_byte header[8];
	const char* filename = [sprite->filePath cString];

  /* This struct contains the JPEG decompression parameters and pointers to
   * working space (which is allocated as needed by the JPEG library).
   */
  struct jpeg_decompress_struct cinfo;
  /* We use our private extension JPEG error handler.
   * Note that this struct must live as long as the main JPEG parameter
   * struct, to avoid dangling-pointer problems.
   */
  struct my_error_mgr jerr;
  /* More stuff */
  FILE * infile;		/* source file */
  JSAMPARRAY buffer;		/* Output row buffer */
  int row_stride;		/* physical row width in output buffer */

  /* In this example we want to open the input file before doing anything else,
   * so that the setjmp() error recovery below can assume the file is open.
   * VERY IMPORTANT: use "b" option to fopen() if you are on a machine that
   * requires it in order to read binary files.
   */

  if ((infile = fopen(filename, "rb")) == NULL) {
    fprintf(stderr, "can't open %s\n", filename);
    return 0;
  }

  /* Step 1: allocate and initialize JPEG decompression object */

  /* We set up the normal JPEG error routines, then override error_exit. */
  cinfo.err = jpeg_std_error(&jerr.pub);
  jerr.pub.error_exit = my_error_exit;
  /* Establish the setjmp return context for my_error_exit to use. */
  if (setjmp(jerr.setjmp_buffer)) {
    /* If we get here, the JPEG code has signaled an error.
     * We need to clean up the JPEG object, close the input file, and return.
     */
    jpeg_destroy_decompress(&cinfo);
    fclose(infile);
    return 0;
  }
  /* Now we can initialize the JPEG decompression object. */
  jpeg_create_decompress(&cinfo);

  /* Step 2: specify data source (eg, a file) */

  jpeg_stdio_src(&cinfo, infile);

  /* Step 3: read file parameters with jpeg_read_header() */

  (void) jpeg_read_header(&cinfo, TRUE);
  /* We can ignore the return value from jpeg_read_header since
   *   (a) suspension is not possible with the stdio data source, and
   *   (b) we passed TRUE to reject a tables-only JPEG file as an error.
   * See libjpeg.doc for more info.
   */

  /* Step 4: set parameters for decompression */

  /* In this example, we don't need to change any of the defaults set by
   * jpeg_read_header(), so we do nothing here.
   */
      
   unsigned int cw = cinfo.image_width;
   unsigned int ch = cinfo.image_height;
   
   // compare just the "dimensions" not the rotation
   // so swap the vars for calculation of scaling.
   if (ch > cw) {
	   
	   unsigned int swap = cw;
	   cw = ch;
	   ch = swap;
   }
   
   float scale_w = 1.;
   float scale_h = 1.;

   if (cw > 1920) {
	   
	   scale_w = (float)cw / 1920.;
   }
   
   if (ch > 1080) {
	   
	   scale_h = (float)ch / 1080.;
   }
   
   if ((scale_w > 1.) || (scale_h > 1.)) {
	   
	   if (scale_w > scale_h) {
		   
   		   cinfo.scale_num = 1000;
		   float fscale_denom = scale_w * cinfo.scale_num;
		   unsigned int scale_denom = (int)fscale_denom;
		   cinfo.scale_denom = scale_denom;
	   } else {
		   
		   cinfo.scale_num = 1000;
		   float fscale_denom = scale_h * cinfo.scale_num;
		   unsigned int scale_denom = (int)fscale_denom;
		   cinfo.scale_denom = scale_denom;
	   }
   }
   

  /* Step 5: Start decompressor */

  (void) jpeg_start_decompress(&cinfo);
  /* We can ignore the return value since suspension is not possible
   * with the stdio data source.
   */

  /* We may need to do some setup of our own at this point before reading
   * the data.  After jpeg_start_decompress() we have the correct scaled
   * output image dimensions available, as well as the output colormap
   * if we asked for color quantization.
   * In this example, we need to make an output work buffer of the right size.
   */ 
  /* JSAMPLEs per row in output buffer */
  row_stride = cinfo.output_width * cinfo.output_components;
  /* Make a one-row-high sample array that will go away when done with image */
  buffer = (*cinfo.mem->alloc_sarray)
		((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
		
  sprite->file_width = cinfo.output_width;
  sprite->file_height = cinfo.output_height;
  sprite->image_data = malloc(cinfo.output_height * cinfo.output_width * 4);	// create buffer for RGBA img

  /* Step 6: while (scan lines remain to be read) */
  /*           jpeg_read_scanlines(...); */

  /* Here we use the library's state variable cinfo.output_scanline as the
   * loop counter, so that we don't have to keep track ourselves.
   */
  char* dest = sprite->image_data;
  NSLog(@"components: %i", cinfo.output_components);
  while (cinfo.output_scanline < cinfo.output_height) {
    /* jpeg_read_scanlines expects an array of pointers to scanlines.
     * Here the array is only one element long, but you could ask for
     * more than one scanline at a time if that's more convenient.
     */
    (void) jpeg_read_scanlines(&cinfo, buffer, 1);
    
    if (cinfo.output_components == 4) {

	    memcpy(buffer[0], dest, row_stride);
	    dest += row_stride; 
	}
	
	if (cinfo.output_components == 3) {
	
		int p;
		char* src = (char*)&buffer[0][0];
		for (p = 0; p < cinfo.output_width; p++) {
			
			// R
			*dest = *src;
			dest++; src++;
			
			// G
			*dest = *src;
			dest++; src++;
			
			// B
			*dest = *src;
			dest++; src++;
			
			// A
			*dest = 0xff;
			dest++;
		}
    }
    
    /* Assume put_scanline_someplace wants a pointer and sample count. */
    //put_scanline_to_image(buffer[0], row_stride);
    //NSLog(@"jpeg scanlin %i", cinfo.output_scanline);
    
    //dest += row_stride; 
    //memcpy(buffer[0], dest, row_stride);
  }
  
   	sprite->imageLoaded = YES;
    NSLog(@"jpg imageWasLoaded");

  /* Step 7: Finish decompression */

  (void) jpeg_finish_decompress(&cinfo);
  /* We can ignore the return value since suspension is not possible
   * with the stdio data source.
   */

  /* Step 8: Release JPEG decompression object */

  /* This is an important step since it will release a good deal of memory. */
  jpeg_destroy_decompress(&cinfo);

  /* After finish_decompress, we can close the input file.
   * Here we postpone it until after no more JPEG errors are possible,
   * so as to simplify the setjmp error logic above.  (Actually, I don't
   * think that jpeg_destroy can do an error exit, but why assume anything...)
   */
  fclose(infile);

  /* At this point you may want to check to see whether any corrupt-data
   * warnings occurred (test whether jerr.pub.num_warnings is nonzero).
   */

  /* And we're done! */
  return 1;
}

/////////////////////////////

void* createThread(void *arg)
{
	NSAutoreleasePool *pool;
	pool = [NSAutoreleasePool new];
	

	BTSprite* sprite = (BTSprite*) arg;

	png_byte header[8];
	const char* file_name = [sprite->filePath cString];

    FILE *fp = fopen(file_name, "rb");
    if (fp == 0)
    {
        perror(file_name);
        RELEASE(pool);	
        return NULL;
    }

    // read the header
    fread(header, 1, 8, fp);

    if (png_sig_cmp(header, 0, 8))
    {
        //fprintf(stderr, "error: %s is not a PNG.\n", file_name);
        fclose(fp);
        RELEASE(pool);	
        
        // No png? Try to load jpg file.
        read_JPEG_file(sprite);
        return NULL;
    }

    png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png_ptr)
    {
        fprintf(stderr, "error: png_create_read_struct returned 0.\n");
        fclose(fp);
        RELEASE(pool);	
        return NULL;
    }

    // create png info struct
    png_infop info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr)
    {
        fprintf(stderr, "error: png_create_info_struct returned 0.\n");
        png_destroy_read_struct(&png_ptr, (png_infopp)NULL, (png_infopp)NULL);
        fclose(fp);
        RELEASE(pool);	
        return NULL;
    }

    // create png info struct
    png_infop end_info = png_create_info_struct(png_ptr);
    if (!end_info)
    {
        fprintf(stderr, "error: png_create_info_struct returned 0.\n");
        png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp) NULL);
        fclose(fp);
        RELEASE(pool);	
        return NULL;
    }

    // the code in this if statement gets called if libpng encounters an error
    if (setjmp(png_jmpbuf(png_ptr))) {
        fprintf(stderr, "error from libpng\n");
        png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
        fclose(fp);
        RELEASE(pool);	
        return NULL;
    }

    // init png reading
    png_init_io(png_ptr, fp);

    // let libpng know you already read the first 8 bytes
    png_set_sig_bytes(png_ptr, 8);

    // read all the info up to the image data
    png_read_info(png_ptr, info_ptr);

    // variables to pass to get info
    int bit_depth, color_type;
    png_uint_32 temp_width, temp_height;

    // get info about png
    png_get_IHDR(png_ptr, info_ptr, &temp_width, &temp_height, &bit_depth, &color_type,
        NULL, NULL, NULL);

	sprite->file_width = temp_width;
	sprite->file_height = temp_height;

    // Update the png info struct.
    png_read_update_info(png_ptr, info_ptr);

    // Row size in bytes.
    int rowbytes = png_get_rowbytes(png_ptr, info_ptr);

    // glTexImage2d requires rows to be 4-byte aligned
    rowbytes += 3 - ((rowbytes-1) % 4);

    // Allocate the image_data as a big block, to be given to opengl
    sprite->image_data = malloc(rowbytes * temp_height * sizeof(png_byte)+15);
    if (sprite->image_data == NULL)
    {
        fprintf(stderr, "error: could not allocate memory for PNG image data\n");
        png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
        fclose(fp);
        RELEASE(pool);	
        return NULL;
    }

    // row_pointers is for pointing to image_data for reading the png with libpng
    png_bytep * row_pointers = malloc(temp_height * sizeof(png_bytep));
    if (row_pointers == NULL)
    {
        fprintf(stderr, "error: could not allocate memory for PNG row pointers\n");
        png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
        free(sprite->image_data);
        fclose(fp);
        RELEASE(pool);	
        return NULL;
    }

    // set the individual row_pointers to point at the correct offsets of image_data
    int i;
    for (i = 0; i < temp_height; i++)
    {      
        row_pointers[i] = sprite->image_data + i * rowbytes;
        
        // Use the commented line, if images are upside down
        // row_pointers[temp_height - 1 - i] = sprite->image_data + i * rowbytes;
    }

    // read the png into image_data through row_pointers
    png_read_image(png_ptr, row_pointers);

	/*
    // Generate the OpenGL texture object
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, temp_width, temp_height, 0, GL_RGB, GL_UNSIGNED_BYTE, image_data);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    */

    // clean up
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
    //free(image_data);
    free(row_pointers);
    fclose(fp);
    
    sprite->imageLoaded = YES;
    NSLog(@"imageWasLoaded");
    
    RELEASE(pool);	

	// exit thread correctly
	return (void *)0;
}


@implementation BTSprite
@synthesize redraw;
@synthesize mipmapfilter;

-(void) initInBackground {
    
    // startup a possix thread
    /*
    // init in thread
	int err;
	err = pthread_create(&(tid), NULL, &createThread, (void*) self);
    if (err != 0) {
      
      printf("\ncan't create thread :[%s]", strerror(err));      
    }
    */
    
    // init immediatlely
    createThread((void*)self);
}

+(BTSprite*) spriteWithFilename:(NSString*)file originX:(float)x originY:(float)y {
    
    BTSprite* sprite = [[BTSprite alloc] init];
    sprite->image_data = NULL;
    sprite->imageLoaded = NO;
    sprite->imagePrepared = NO;
    sprite->filePath = [file retain];
    sprite->initialized = NO;
    sprite->mode = MODE_ORIGIN;
    sprite->originX = x;
    sprite->originY = y;
    
    
    NSRange range = [file rangeOfString:@"@2x"];
    if (range.location == NSNotFound) {
        
        sprite->doubleSized = NO;
    } else {
        
        sprite->doubleSized = YES;
    }
    
    // Turn off, if you need to stack some images over each other
    // to avoid sharp edges
    sprite.mipmapfilter = YES;
    
    [sprite initInBackground];
    
    return [sprite autorelease];
}

+(BTSprite*) spriteWithFilename:(NSString*)file centerX:(float)x centerY:(float)y {
    
    BTSprite* sprite = [[BTSprite alloc] init];
    sprite->image_data = NULL;
    sprite->imageLoaded = NO;
    sprite->imagePrepared = NO;
    sprite->filePath = [file retain];
    sprite->initialized = NO;
    sprite->mode = MODE_CENTER;
    sprite->centerX = x;
    sprite->centerY = y;
    
    
    NSRange range = [file rangeOfString:@"@2x"];
    if (range.location == NSNotFound) {
        
        sprite->doubleSized = NO;
    } else {
        
        sprite->doubleSized = YES;
    }
    
    // Turn off, if you need to stack some images over each other
    // to avoid sharp edges
    sprite.mipmapfilter = YES;
    
    [sprite initInBackground];
    
    
    return [sprite autorelease];
}

+(BTSprite*) spriteWithFilename:(NSString*)file frame:(CGRect)frame {
    
    BTSprite* sprite = [[BTSprite alloc] init];
    sprite->image_data = NULL;
    sprite->imageLoaded = NO;
    sprite->imagePrepared = NO;
    sprite->filePath = [file retain];
    sprite->initialized = NO;
    sprite->mode = MODE_RECT;
    sprite->frame = frame;
    
    NSRange range = [file rangeOfString:@"@2x"];
    if (range.location == NSNotFound) {
        
        sprite->doubleSized = NO;
    } else {
        
        sprite->doubleSized = YES;
    }
    
    // Turn off, if you need to stack some images over each other
    // to avoid sharp edges
    sprite.mipmapfilter = YES;
    
    [sprite initInBackground];
    
    
    return [sprite autorelease];
}


//#pragma mark sprite implementation
-(void) renderAtTime:(NSTimeInterval)t {

    if (!self->imageLoaded) {
        
        [super forwardTransform];	
        [super renderAtTime:t];
        [super backwardTransform];

        return;
    } else {
        
        if (!self->imagePrepared) {
            
            self->imagePrepared = YES;            
            
            switch (self->mode) {
                case MODE_ORIGIN: {

                    self->x = originX;
                    self->y = originY;                    
                    
                    if (self->doubleSized) {
                        
                        self.width = file_width / 2.;
                        self.height = file_height / 2.;
                        self->anchor_x = self.width / 2.;
                        self->anchor_y = self.height / 2.;
                        self->x += self->anchor_x;
                        self->y += self->anchor_y;
                        self->scale_x = 0.5;
                        self->scale_y = 0.5;
                    } else {
                        
                        self.width = file_width;
                        self.height = file_height;
                        self->anchor_x = self.width / 2.;
                        self->anchor_y = self.height / 2.;
                        self->x += self->anchor_x;
                        self->y += self->anchor_y;
                    }
                } break;
                    
                case MODE_CENTER: {

                    self->x = centerX;
                    self->y = centerY;
                    if (self->doubleSized) {

                        self.width = file_width / 2.;
                        self.height = file_height / 2.;
                        self->anchor_x = file_width / 4.;
                        self->anchor_y = file_height / 4.;
                        self->scale_x = 0.5;
                        self->scale_y = 0.5;
                    } else {

                        self.width = file_width;
                        self.height = file_height;
                        self->anchor_x = self.width / 2.;
                        self->anchor_y = self.height / 2.;
                    }
                } break;
                    
                case MODE_RECT: {
                    
                    self->x = self->frame.origin.x;
                    self->y = self->frame.origin.y;

                    // init Width
                    self.width = file_width;
                    self.height = file_height;
                    
                    // set destination width
                    self.width = self->frame.size.width;
                    self.height = self->frame.size.height;
                    //sprite.center_x = sprite.width / 2.;
                    //sprite.center_y = sprite.height / 2.;
                    self->x += self->anchor_x;
                    self->y += self->anchor_y;
                } break;

                default:
                    break;
            }
        }
    }

    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    aF = self.alphaFade;
    cF = self.colorFade;

    glColor4f(cF, cF, cF, aF);
    
    [self forwardTransform];

    if (initialized && !self.redraw) {
    
        glBindTexture(GL_TEXTURE_2D, texture);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
		
        /*
        if (self.mipmapfilter) {

            //glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, GL_TRUE);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        } else {
            
            // HINT: USE GL_NEAREST. GL_LINEAR will cause sharp edges wen images are stacked as overlay
            //glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, GL_FALSE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        }
        */

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glVertexPointer( 2, GL_FLOAT, 0, (char*) NULL );
        glBindBuffer(GL_ARRAY_BUFFER, vbo_texture_coords);
		glTexCoordPointer( 2, GL_FLOAT, 0, (char*) NULL );

        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 5);

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);

        //glDisable(GL_TEXTURE_2D);
    } else {

        if (!initialized) {
            
            glGenTextures(1, &texture);
            glGenBuffers(1, &vbo);
            glGenBuffers(1, &vbo_texture_coords);
            initialized = YES;
        }

        glBindTexture(GL_TEXTURE_2D, texture);             		          
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, file_width, file_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, self->image_data);
		free(self->image_data);
		self->image_data = NULL;

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        /*
        if (self.mipmapfilter) {
        
           // glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, GL_TRUE);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        } else {
        
            // HINT: USE GL_NEAREST. GL_LINEAR will cause sharp edges wen images are stacked as overlay
            //glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, GL_FALSE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        }
        */
          
        // vertices
        GLfloat vertices[] = {
            0., 0.,
            file_width, 0.,
            file_width, file_height,
            0., file_height,
            0., 0.
        };
        
        GLfloat tex_coords[] = {
            
            0., 0.,
            1., 0.,
            1., 1.,
            0., 1.,
            0., 0.
        };
        
        if (self->imageLoaded) {

            // Prepare vertex buffer objects
            glEnableClientState(GL_VERTEX_ARRAY);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            
            glBindBuffer(GL_ARRAY_BUFFER, vbo);
            glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
            glVertexPointer(2, GL_FLOAT, 0, NULL);

            glBindBuffer(GL_ARRAY_BUFFER, vbo_texture_coords);
            glBufferData(GL_ARRAY_BUFFER, sizeof(tex_coords), tex_coords, GL_STATIC_DRAW);
            glTexCoordPointer(2, GL_FLOAT, 0, NULL);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 5);
            
            // unbind buffers
            glBindBuffer(GL_ARRAY_BUFFER, 0);
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
            glDisableClientState(GL_VERTEX_ARRAY);

            initialized = YES;
            self.redraw = NO;
        }
        
        glDisable(GL_TEXTURE_2D);
    }
    
    // Call super class at the end to enable tree traversal
    [super renderAtTime:t];
    [self backwardTransform];
}

-(void) dealloc {
	
	NSLog(@"Sprite dealloc");
	
	NSLog(@"deleting filePath var");
	if (self->filePath) {
	
		NSLog(@"filePath retainCount: %i", [self->filePath retainCount]);
		[self->filePath release];
		self->filePath = nil;
	}	
	
	NSLog(@"deleting bitmap_data");
	if (self->image_data) {
		
		free(self->image_data);
	}
	
	NSLog(@"calling Atoms 'dealloc'");
	[super dealloc];	
}
@end
