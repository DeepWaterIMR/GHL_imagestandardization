imstand_create_manual_lupetest <- function(imno,adj,fillparam,pathraw,pathprocessed){
# creates standard 256 X 256 X 3 right otolith image, manual framing


# INPUT
# imno = otolith number (1-n)
# adj = adjustment of intensity threshold ()
# fillparam = parameter defining the morphological filter size used to fill holes within the otolith contour.  Must be an odd number!
# pathraw = path to input images
# pathprocessed = path where the processed images should be saved   

# OUTPUT
#Image in jpg format. The first part of the title is similar as the input file name, the second specifies that the image is standardized, and provides a numerated index. 

  

  setwd(pathraw)# path to catalogue with raw images

na<-list.files()
      	
          	imagetest <- function(){ 
  ntest<-readline(prompt="image ok? (yes=1, no=0): ");
  ntest <-as.integer(ntest)
    if(ntest==1){
  listn<-ntest
  listn<-list(ntest)}
  if (ntest==0){
    cat("adjustmentfactor=",adj)  
    n0<-readline(prompt="new threshold adjustment: ")
    adj<-as.numeric(n0)
    cat("fill parameter=",fillparam)  
    n1<-readline(prompt="new fill parameter: ")
    fillparam<-as.numeric(n1)
    listn<-list(ntest,adj,fillparam)}
  return(listn)
  }


ok <- 0# ok = 1 when standard image looks ok
scales<-256
print(sprintf("Image nr %d",imno))



nashort <- na[imno]# converts filename to character

while (ok == 0){
im <- stack(nashort)


if(max(values(im))>256){
im<-im/256
}

siz <- dim(im)# im size, siz(1) = #rows, siz(2) = #columns


   par(bg = 'black',mfrow=c(1,1))

plotRGB(im)
 
      xxyy<-locator(2,type="o")# reads upper left and lower right corners
        xx <- round(xxyy$x)
        yy <- round(xxyy$y)
        newdim<-extent(xx[1],xx[2],yy[2],yy[1])
        imright <- crop(im,newdim)# right otolith part

    im <- imright
    
 
    # Separate the individual raster layers
    rgbs<-as.list(im)
    imr<-rgbs[[1]] # red component of im
    img<-rgbs[[2]] # green component of im 
    imb<-rgbs[[3]]# blue component of im
    siz <- dim(im)


    #Isolate the blue component of image, convert to binary set of pixels using imager::threshold. Without further specification, imager::threshold will automatically choose the threshold value using a k-means clustering method. The output imbw is an image with 4 dimensions Width, Height, Depth, Colour channels.  
  
#  adj = mean(getValues(imb))/256+0.6
#  print(adj)
    
    
    
  imbw<-1-imager::threshold(as.cimg(imb),adjust=adj)
  imbw<-fill(imbw,fillparam)

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
    jb <- setdiff(union(a,b),intersect(a,b))
    
    #The background color for the red-, green- and blue-component images is now changed to black color, by replacing all indices [jb] to value 0 (zero indicates black color in raster layer format) 
    # Allocate 0's to all background pixels for red, green and blue comp.
    
    imr[jb] <- 0 # allocates 0 to background red-pixels
    img[jb] <- 0# allocates 0 to background green-pixels
    imb[jb] <- 0# allocates 0 to background blue-pixels
    
    
    #Finally, the red- green and blue component raster layers are bricked together to obtain the complete three-layer raster. 

 
 #Here is the new image with otolith in color, and black background. 

    
    imrc<-autocrop(as.cimg(imr))
    imgc<-autocrop(as.cimg(img))
    imbc<-autocrop(as.cimg(imb))
    
    
     nr<-max(dim(imrc)[1:2])
     cr<-min(dim(imrc)[1:2])
     
     
    sizbox = dim(imrc)  # extends box so that otolith extension fills 90 % of image extension
    lsiz = ceiling(max(sizbox)*1.1)      # in some cases the extension might be in the x-direction

    
    imr<-raster(cimg2Raster(imrc))
    img<-raster(cimg2Raster(imgc))
    imb<-raster(cimg2Raster(imbc))

 
     dlx1 <- floor((lsiz-cr)/2)# number of extension pixels to the left of otolith
     dlx2 <- lsiz-cr-dlx1# number of extension pixels to the right of otolith
     dly1 <- floor((lsiz-nr)/2)# number of extension pixels above otolith
     dly2 <- lsiz-nr-dly1# number of extension pixels below otolith
    

     imrc2<-pad(imrc,dlx1,pos=-1,"x")  
     imrc2<-pad(imrc2,dlx2,pos=1,"x")   
     imrc2<-pad(imrc2,dly1,pos=-1,"y")
     imrc2<-pad(imrc2,dly2,pos=1,"y")
     
     imgc2<-pad(imgc,dlx1,pos=-1,"x")  
     imgc2<-pad(imgc2,dlx2,pos=1,"x")   
     imgc2<-pad(imgc2,dly1,pos=-1,"y")
     imgc2<-pad(imgc2,dly2,pos=1,"y")
  
     imbc2<-pad(imbc,dlx1,pos=-1,"x")  
     imbc2<-pad(imbc2,dlx2,pos=1,"x")   
     imbc2<-pad(imbc2,dly1,pos=-1,"y")
     imbc2<-pad(imbc2,dly2,pos=1,"y")
     
     imrc3<-imager::resize(imrc2,scales,scales)
     imgc3<-imager::resize(imgc2,scales,scales)
     imbc3<-imager::resize(imbc2,scales,scales)

     imr<-raster(cimg2Raster(imrc3))
     img<-raster(cimg2Raster(imgc3))
     imb<-raster(cimg2Raster(imbc3))
          
     imnew<-brick(imr,img,imb)

          
          par(bg = 'black',mfrow=c(1,2))
          plotRGB(im)   
          plotRGB(imnew)

 okout<-imagetest()
 
 ok<-okout[[1]]

 if (length(okout)>1){
newadj<-okout[[2]]
newfillparam<-okout[[3]]
  adj<-newadj;
  fillparam<-newfillparam
  }

 }
str<-paste(pathprocessed, substr(nashort,1,23),sprintf("_loopnr_%d_standard.jpg",imno),sep='')           
jpeg(file=str,w=scales,h=scales,bg="black")
plotRGB(imnew)
dev.off()
}