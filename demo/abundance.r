# rgl-demo: animal abundance
# author: Oleg Nenadic, Daniel Adler
# $Id: abundance.r,v 1.1 2004/02/29 12:00:48 dadler Exp $

########
##### Animal abundance:
########

# Clearing the Scene:

# remove all shapes
rgl.clear()
# remove all lights
rgl.clear(type="lights")
# disable bounding-box
rgl.clear(type="bbox")

# setup background
rgl.bg(color="gray")
# setup head-light
rgl.light()

# Importing the animal data (created with wisp)
test<-dget(system.file("demo/region.dat",package="rgl"))
pop<-dget(system.file("demo/population.dat",package="rgl"))

# Defining colors for the 'terrain':
zlim <- range(test)
zlen <- zlim[2] - zlim[1] + 1
colorlut <- terrain.colors(82) 
col1 <- colorlut[9*sqrt(3.6*(test-zlim[1])+2)]

# Setting colour to blue for regions with zero 'altitude':
col1[test==0]<-"#0000FF"

# Drawing the 'landscape' (i.e. population density):
rgl.surface(1:100,seq(1,60,length=100),test,col=col1,spec="#000000",
            ambient="#333333",back="lines")

# Setting the background to lightgrey:
rgl.bg(col="#cccccc")

# Defining colours for simulated populations (males:blue, females:red):
col2<-pop[,4]
col2[col2==0]<-"#3333ff"
col2[col2==1]<-"#ff3333"

# Adding simulated populations as spheres to the plot:
for(i in 1:100)
  {rgl.spheres(pop[i,1],test[ceiling(pop[i,1]),ceiling(pop[i,2]*10/6)]+0.5,
               pop[i,2],radius=0.2*pop[i,3],col=col2[i],alpha=(1-(pop[i,5])/10))
  }


