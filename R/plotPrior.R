#' Plot Prior Distribution
#' 
#' This function will plot the distribution of priors
#' @param priorFn Prior shape; either "fixed", "uniform", "normal", "lognormal", "gamma", or "exponential"
#' @param priorVariables Variables needed to describe the shape of the distribution.  uniform distributions=c(min, max); normal distributions=c(mean, sd); lognormal distributions=c(mean, sd); gamma distributions=c(shape, scale); exponential distributions=c(rate)
#' @param plotQuants If TRUE, plots line segments at the quantiles
#' @param plotLegend If TRUE, plots legend box with quantile values
#' @export
#' @return Returns a distribution plot
#' @examples
#' plotPrior(priorFn="exponential", priorVariables=c(10))	
#' plotPrior("normal", c(1,2))
#' plotPrior("gamma", c(2, .2), plotQuants=FALSE, plotLegend=FALSE)

plotPrior <- function(priorFn, priorVariables, plotQuants=TRUE, plotLegend=TRUE){
  priorFn <- match.arg(arg=priorFn,choices=c("fixed", "uniform", "normal", "lognormal", "gamma", "exponential"),several.ok=FALSE)
  x <- NA
  quant <- c(0.01, 0.05, 0.25, .50, 0.75, 0.95, 0.99)
  quant.value <- NULL
  mm <- NULL
  if(priorFn == "fixed")
    return("can't plot fixed prior")
  else if (priorFn == "uniform"){
    min <- priorVariables[1]
    max <- priorVariables[2]
    x <- runif(1000, min, max)
    curve(dunif(x), xlim=c(min-(.3*(max-min)), max+(.3*(max-min))), ylim=c(0, 1.5), type="n", xlab="", ylab=paste("Density (parameters: min=", min, "; max =", max, ")", sep=""))
    rect(min, 0, max, 1, col=rgb(0, 0, 0, .2))
    for (i in 1:length(quant)){
      quant.value[i] <- qunif(quant[i], min, max)	
      if (plotQuants){
        segments(quant.value[i], 0, quant.value[i], 1)
        segments(qunif(.5, min, max), 0, qunif(.5, min, max), 1, lwd=2)
      }
    }
  }
  else if(priorFn == "normal"){
    mean <- priorVariables[1]
    stdev <- priorVariables[2]
    x <- rnorm(1000, mean, stdev)
    poly <- curve(dnorm(x, mean, stdev), from=min(x), to=max(x), xlab="", ylab=paste("Density (parameters: mean=", mean, "; stdev =",stdev, ")", sep=""))
    poly$x <- c(min(poly$x),poly$x, max(poly$x))
    poly$y <- c(min(poly$y), poly$y, min(poly$y))
    polygon(poly, col=rgb(0, 0, 0, 0.3)) 
    for(i in 1:length(quant)) {
    quant.value[i] <- qnorm(quant[i], mean, stdev)
      if(plotQuants){
        mm[i] <- dnorm(quant.value[i], mean, stdev)
        segments(quant.value[i], min(poly$y), quant.value[i], mm[i])
        segments(qnorm(.5, mean, stdev), min(poly$y), qnorm(.5, mean, stdev), dnorm(qnorm(.5, mean, stdev), mean, stdev), lwd=2)
      }
    }
  }
  else if(priorFn == "lognormal"){  #messed up quant lines and polygon
    mean <- priorVariables[1]
    stdev <- priorVariables[2]
    x <- rlnorm(1000, mean, stdev)
    poly <- curve(dlnorm(x, mean, stdev), from=0, to=qlnorm(0.99, mean, stdev), xlab="", ylab=paste("Density (parameters: mean=", mean, "; stdev =",stdev, ")", sep=""))
    poly$x <- c(poly$x, max(poly$x))
    poly$y<-c(poly$y, min(poly$y))
    polygon(poly, col=rgb(0, 0, 0, 0.3))  
    for (i in 1:length(quant)){
      quant.value[i] <- qlnorm(quant[i], mean, stdev)
      if(plotQuants){
        mm[i] <- dlnorm(quant.value[i], mean, stdev)
        segments(quant.value[i], min(poly$y), quant.value[i], mm[i])
        segments(qlnorm(.5, mean, stdev), min(poly$y), qlnorm(.5, mean, stdev), dlnorm(qlnorm(.5, mean, stdev), mean, stdev), lwd=2)
      }
    }
  }
  else if(priorFn == "gamma"){
    shape <- priorVariables[1]
    scale <- priorVariables[2]
    x <- rgamma(1000, shape, scale)
    poly <- curve(dgamma(x, shape, scale), from=0, to=qgamma(0.99, shape, scale), xlab="", ylab=paste("Density (parameters: shape=", shape, "; scale =",scale, ")", sep=""))
    poly$x <- c(0, poly$x, max(poly$x), 0)
    poly$y <- c(0, poly$y, min(poly$y), 0)
    polygon(poly, col=rgb(0, 0, 0, 0.3)) 
    for (i in 1:length(quant)) {
      quant.value[i] <- qgamma(quant[i], shape, scale)
      if (plotQuants){
        mm[i] <- dgamma(quant.value[i], shape, scale)
        segments(quant.value[i], min(poly$y), quant.value[i], mm[i])
        segments(qgamma(.5, shape, scale), min(poly$y), qgamma(.5, shape, scale), dgamma(qgamma(.5, shape, scale), shape, scale), lwd=2)
      }
    }
  }
  else if (priorFn == "exponential"){
    rate <- priorVariables[1]
    x <- rexp(1000, rate)
    poly <- curve(dexp(x, rate), from=0, to=qexp(0.99, rate), xlab="", ylab=paste("Density (parameters: rate=", rate, ")", sep=""))
    poly$x <- c(poly$x, 0)
    poly$y <- c(poly$y, min(poly$y))
    polygon(poly, col=rgb(0, 0, 0, 0.3))
    for(i in 1:length(quant)) {
      quant.value[i] <- qexp(quant[i], rate)
      if(plotQuants){
        mm[i] <- dexp(quant.value[i], rate)
        segments(quant.value[i], min(poly$y), quant.value[i], mm[i])
        segments(qexp(.5, rate), min(poly$y), qexp(.5, rate), dexp(qexp(.5, rate), rate), lwd=2)
      }
    }
  }
  results <- data.frame(cbind(quant, quant.value))
  if(plotLegend)
    legend("topright", legend=paste(c(quant, signif(quant.value, digits=3))), title="Quantiles", ncol=2, bty="n")
  return(results)	
}