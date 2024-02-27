library(pvclust)
library(ape)

as.phylo.pvclust <- function (pvclust_object,nodelabels="AU",roundvalue=2,terminals=0.05,...) 
{
  x <- pvclust_object$hclust
  #number of groups in hclust object
  N <- dim(x$merge)[1]
  #getting edge matrix
  edge <- matrix(0L, 2 * N, 2)
  #getting edge.length vector
  edge.length <- numeric(2 * N)
  #getting vector of nodes
  node <- integer(N)
  node[N] <- N + 2L
  cur.nod <- N + 3L
  j <- 1L
  for (i in N:1) {
    edge[j:(j + 1), 1] <- node[i]
    for (l in 1:2) {
      k <- j + l - 1L
      y <- x$merge[i, l]
      
      if (y > 0) {
        edge[k, 2] <- node[y] <- cur.nod
        cur.nod <- cur.nod + 1L
        edge.length[k] <- x$height[i] - x$height[y]
      }
      else {
        edge[k, 2] <- -y
        if (terminals=="NA"){
          edge.length[k] <- x$height[i]
        }
        else {
          edge.length[k] <- terminals
        }
      }
    }
    j <- j + 2L
  }
  node.label <- numeric(N)
  if (nodelabels=="AU"){
    probs <- round(pvclust_object$edges[,1],digits=roundvalue)
    node.label[node-N-1] <- probs
    node.label[1] <- NA
  }
  else {
    if (nodelabels=="BP"){
      probs <- round(pvclust_object$edges[,2],digits=roundvalue)
      node.label[node-N-1] <- probs
      node.label[1] <- NA
    }
    else {
      node.label[] <- NA   
    }
  }
  if (is.null(x$labels)) 
    x$labels <- as.character(1:(N + 1))
  obj <- list(edge = edge, edge.length = edge.length/2, tip.label = x$labels, 
              Nnode = N,node.label=node.label)
  class(obj) <- "phylo"
  reorder(obj)
  
}