#' @title Standardize otolith picture for age estimation by deep learning
#' @description Standardizes otolith images ready age estimation by deep learning. Creates a 256 X 256 X 3 right otolith image with manual framing.
#' @param imno Integer giving the otolith number, i.e. the file serial number in \code{list.files(pathraw)}.
#' @param adj Numeric defining the intensity threshold. Good starting values may be 1 to 1.5. 
#' @param fillparam Integer defining the morphological filter size used to fill holes within the otolith contour. Must be an odd number. 
#' @param pathraw Character defining the file path to input images.
#' @param pathprocessed Character defining the file path where the processed images should be saved.
#' @param postfix Character or function defining the postfix for the image file. 
#' @param adjust_param Logical indicating whether the function should ask new threshold (\code{adj}) and fill (\code{fillparam}) parameters when the user is not satisfied with the image quality. 
#' @return Saves a jpg image in \code{pathprocessed}. The first part of the file name is similar as the input file name, the second part is taken from \code{postfix}
#' @author Tine Nilsen, Mikko Vihtakari, Kristin Windsland (Institute of Marine Research, Norway)

# Debugging parameters:
# imno = 1; adj = 1.35; fillparam = 15; pathraw = normalizePath('/Users/a22357/Library/CloudStorage/OneDrive-SharedLibraries-Havforskningsinstituttet/Nilsen, Tine - GHL_imagestandardization/Råbilder_gammellupe'); pathprocessed = 'Prosesserte_gammellupe/'; postfix = sprintf("_loopnr_%d_standard.jpg", imno)
standardize_image <- function(
    imno, adj = 1.2, fillparam = 9, pathraw, pathprocessed, 
    postfix = sprintf("_loopnr_%d_standard.jpg", imno), 
    adjust_param = FALSE
    ) {
  
  if(!dir.exists(pathraw)) {
    stop(pathraw, " does not exist. Check the file path")
  }
  
  if(!dir.exists(pathprocessed)) {
    ret.val <- utils::menu(
      choices = c("Yes", "No"), 
      title = paste(pathprocessed, "does not exist. Do you want to create the folder?")
    )
    
    if(ret.val != 1) {
      msg <- paste0(pathprocessed, " does not exist. Check the file path or create the folder.")
      stop(paste(strwrap(msg), collapse= "\n"))
    } else {
      dir.create(pathprocessed)
      msg <- paste0("Folder ", pathprocessed, " created")
      message(paste(strwrap(msg), collapse= "\n"))
    } 
  }
  
  imagetest <- function() { 
    ntest <- readline(prompt = "Image ok? (1 or enter = yes, anything else = no): ");
    if(ntest == "" | ntest == 1) ntest <- 1 else ntest <- 0
    if(ntest == 1) {
      listn <- ntest
      listn <- list(ntest)
    } else {
      if(adjust_param) {
      cat("Adjustment factor (adj) = ", adj)  
      n0 <- readline(prompt = "New threshold adjustment: ")
      adj <- as.numeric(n0)
      cat("Fill parameter (fillparam) = ",fillparam)  
      n1 <- readline(prompt = "New fill parameter: ")
      fillparam <- as.numeric(n1)
      }
      
      listn <- list(ntest, adj, fillparam)
    }
    
    return(listn)
  }
  
  
  ok <- 0 # ok = 1 when standard image looks ok
  scales<-256
  print(sprintf("Image nr %d",imno))
  
  nashort <- normalizePath(list.files(pathraw, full.names = TRUE)[imno]) # converts filename to character
  naname <- list.files(pathraw)[imno]
  
  while (ok == 0){
    im <- suppressWarnings(raster::stack(nashort))
    
    if(suppressWarnings(max(raster::values(im))>256)) {
      suppressWarnings({im <- im/256})
    }
    
    siz <- dim(im)# im size, siz(1) = #rows, siz(2) = #columns
    
    ## Plot
    graphics::par(bg = 'black',mfrow=c(1,1))
    
    raster::plotRGB(im)
    message("Press the picture twice to define the corners of the otolith photo. These corners will be used for cropping.")
    
    xxyy <- graphics::locator(2, type = "o") # reads upper left and lower right corners
    xx <- round(xxyy$x)
    yy <- round(xxyy$y)
    newdim <- raster::extent(xx[1],xx[2],yy[2],yy[1])
    im <- raster::crop(im, newdim) # right otolith 
    
    # Separate the individual raster layers
    rgbs <- as.list(im)
    imr <- rgbs[[1]] # red component of im
    img <- rgbs[[2]] # green component of im 
    imb <- rgbs[[3]] # blue component of im
    siz <- dim(im)
    
    #Isolate the blue component of image, convert to binary set of pixels using imager::threshold. Without further specification, imager::threshold will automatically choose the threshold value using a k-means clustering method. The output imbw is an image with 4 dimensions Width, Height, Depth, Colour channels.  
    
    #  adj = mean(getValues(imb))/256+0.6
    #  print(adj)
    
    imbw <- 1 - imager::threshold(imager::as.cimg(imb), adjust = adj)
    imbw <- imager::fill(imbw,fillparam)
    
    #Check if grayscale image has black background in all corners
    
    #corners<-c(imbw[1,1],imbw[1,dim(imbw)[2]],imbw[dim(imbw)[1],1],imbw[dim(imbw)[1],dim(imbw)[2]])
    #if(any(corners!=0)){
    #print("you should check the background in the four corners")}
    
    jw <- which(imbw == 1)# indices to white pixels in bw image
    
    rows = ((jw-1) %% siz[1]) + 1
    cols = floor((jw-1) / siz[1]) + 1
    
    # finds indices to black pixels in bw image:
    a<-seq(1,(siz[1]*siz[2]))
    b<-jw
    jb <- setdiff(union(a,b), intersect(a,b))
    
    #The background color for the red-, green- and blue-component images is now changed to black color, by replacing all indices [jb] to value 0 (zero indicates black color in raster layer format) 
    # Allocate 0's to all background pixels for red, green and blue comp.
    
    imr[jb] <- 0 # allocates 0 to background red-pixels
    img[jb] <- 0# allocates 0 to background green-pixels
    imb[jb] <- 0# allocates 0 to background blue-pixels
    
    #Finally, the red- green and blue component raster layers are bricked together to obtain the complete three-layer raster. 
    
    
    #Here is the new image with otolith in color, and black background. 
    
    imrc <- imager::autocrop(imager::as.cimg(imr))
    imgc <- imager::autocrop(imager::as.cimg(img))
    imbc <- imager::autocrop(imager::as.cimg(imb))
    
    nr<-max(dim(imrc)[1:2])
    cr<-min(dim(imrc)[1:2])
    
    
    sizbox = dim(imrc)  # extends box so that otolith extension fills 90 % of image extension
    lsiz = ceiling(max(sizbox)*1.1)      # in some cases the extension might be in the x-direction
    
    imr <- raster::raster(lidaRtRee::cimg2Raster(imrc))
    img <- raster::raster(lidaRtRee::cimg2Raster(imgc))
    imb <- raster::raster(lidaRtRee::cimg2Raster(imbc))
    
    dlx1 <- floor((lsiz-cr)/2)# number of extension pixels to the left of otolith
    dlx2 <- lsiz-cr-dlx1# number of extension pixels to the right of otolith
    dly1 <- floor((lsiz-nr)/2)# number of extension pixels above otolith
    dly2 <- lsiz-nr-dly1# number of extension pixels below otolith
    
    
    imrc2 <- imager::pad(imrc,dlx1,pos=-1,"x")  
    imrc2 <- imager::pad(imrc2,dlx2,pos=1,"x")   
    imrc2 <- imager::pad(imrc2,dly1,pos=-1,"y")
    imrc2 <- imager::pad(imrc2,dly2,pos=1,"y")
    
    imgc2 <- imager::pad(imgc,dlx1,pos=-1,"x")  
    imgc2 <- imager::pad(imgc2,dlx2,pos=1,"x")   
    imgc2 <- imager::pad(imgc2,dly1,pos=-1,"y")
    imgc2 <- imager::pad(imgc2,dly2,pos=1,"y")
    
    imbc2 <- imager::pad(imbc,dlx1,pos=-1,"x")  
    imbc2 <- imager::pad(imbc2,dlx2,pos=1,"x")   
    imbc2 <- imager::pad(imbc2,dly1,pos=-1,"y")
    imbc2 <- imager::pad(imbc2,dly2,pos=1,"y")
    
    imrc3 <- imager::resize(imrc2,scales,scales)
    imgc3 <- imager::resize(imgc2,scales,scales)
    imbc3 <- imager::resize(imbc2,scales,scales)
    
    imr <- raster::raster(lidaRtRee::cimg2Raster(imrc3))
    img <- raster::raster(lidaRtRee::cimg2Raster(imgc3))
    imb <- raster::raster(lidaRtRee::cimg2Raster(imbc3))
    
    imnew <- raster::brick(imr,img,imb)
    
    
    par(bg = 'black',mfrow=c(1,2))
    raster::plotRGB(im)   
    raster::plotRGB(imnew)
    
    okout <- imagetest()
    
    ok <- okout[[1]]
    
    if (length(okout)>1){
      newadj<-okout[[2]]
      newfillparam<-okout[[3]]
      adj<-newadj;
      fillparam<-newfillparam
    }
    
  }
  
  output_file <- file.path(
    pathprocessed, 
    paste0(tools::file_path_sans_ext(naname), postfix)
  )
  
  grDevices::jpeg(file = output_file, w = scales, h = scales, bg = "black")
  raster::plotRGB(imnew)
  grDevices::dev.off()
  message(output_file, " created")
}