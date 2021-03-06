library(RCurl)#for ftp
library(httr)
library(plyr)

# lines <- readLines("test.csv")
# lines <- gsub('"', '', lines, fixed=TRUE)
# data <- read.csv(textConnection(lines), header=FALSE)


#Execution of a shell script 
system("bash argo.sh")

maxparam <- max(count.fields("ArgoIdParameters.csv", sep = ','))#max number of parameters 
argo_param <- read.csv(file = "ArgoIdParameters.csv", sep = ",", na.strings="NA", 
                 col.names = paste0("V", seq_len(maxparam), fill=TRUE), 
                 header = FALSE)


#Merge profile download
source_url <-"ftp://ftp.ifremer.fr/ifremer/argo/etc/netcdf4/dac/"

#ARGO identification number
WOD <- c("6902734","1901206")
group <- c("bodc","coriolis")

userpwd <-"anonymous: "

urldf <- ldply(as.list(1:length(WOD)), function(i){
  url <- paste0(source_url,group[i],"/",WOD[i],"/")
  data.frame(url = url)
})

for (i in 1:length(filenames)){
  filenames <- getURL(urldf$url[i], userpwd = userpwd,
                      ftp.use.epsv = FALSE,dirlistonly = TRUE) 
  file <- paste(urldf$url[i], strsplit(filenames, "\r*\n")[[1]], sep = "")
  GET(url=file, write_disk(paste0(WOD[i],"_MProf.nc", overwrite=T)))
}

#Note: C'est plus pour "nous", le code shell n'est de toute façon pas adapté
#pour windows..

#les utilisateurs de la toolbox, s'ils ne sont pas vraiment au courant, 
#pourront ainsi connaitre les capteurs des bouées de la zone qui les 
#intéresse (à condition qu'ils connaissent également l'identifiant des bouées,
#on pourrait aussi proposer une map, pas simple à mettre en place mais c'est
#"user-friendly" [on s'ouvre à tout le monde..]

#Note2: On pourrait également proposer un code pour le téléchargement de
#merge profiles via le ftp (via RCurl par exemple si c'est possible) une fois
#que les identifiants seront choisis par l'utilisateur?

#Note3: Pas simple de trouver un moyen de contourner la cessation nette des
#activités de R si l'utilisateur entre un paramètre qui ne se trouve pas dans
#un fichier NetCDF...

