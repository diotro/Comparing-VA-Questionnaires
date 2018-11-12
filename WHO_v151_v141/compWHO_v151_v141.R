#--------------------------------------------------------------------------------------------------------------------------------------#
#  compWHO_v151_v141.R
#
#  created:        2018/09/06
#  last modified:  2018/09/06
#
#  Notes
#
#  (1)
#
#--------------------------------------------------------------------------------------------------------------------------------------#

date()
#--------------------------------------------------------------------------------------------------------------------------------------#
# 1: LOAD LIBRARIES & DATA
#--------------------------------------------------------------------------------------------------------------------------------------#
dir()
library(stringdist)
library(stringr)
library(readxl)

## 2016 ##
#### version 2 ####
rawVA16V2.1 <- read_xlsx("08_1_WHOVA2016_v1_5_1_XLS_form_for_ODK.xlsx", sheet = 1)
names(rawVA16V2.1)

rawVA16V2.2 <- read_xlsx("08_1_WHOVA2016_v1_5_1_XLS_form_for_ODK.xlsx", sheet = 2)
names(rawVA16V2.2)

#### version 1 ####
rawVA16V1.1 <- read_xlsx("WHOVA2016_v1_4_1_XLS_form_for_ODK.xlsx", sheet = 1)
names(rawVA16V1.1)

rawVA16V1.2  <- read_xlsx("WHOVA2016_v1_4_1_XLS_form_for_ODK.xlsx", sheet = 2)
names(rawVA16V1.2)

#--------------------------------------------------------------------------------------------------------------------------------------#
# 2: CLEAN ORIGINAL DATA BY REMOVING BLANK LINES, REMOVING TYPE "END GROUP", AND CONVERTING QUOTES & NEW LINES
#--------------------------------------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------------------------------------#
## 2016 version 2 ##
#### first worksheet (also cleaning "label..English" field) ####
va16v2.1.valid <- !is.na(rawVA16V2.1$name)
table(va16v2.1.valid)

va16v2.1 <- rawVA16V2.1[va16v2.1.valid,]
dim(va16v2.1)
dim(rawVA16V2.1)

###### add sequence number ######
va16v2.1$seq <- 1:nrow(va16v2.1)

###### some characters, e.g. ' and newline, are imported as markup code; examples... ######
va16v2.1$"hint::English"

va16v2.1$"hint::English"[grep("\xd2", va16v2.1$"hint::English", useBytes=TRUE)]
va16v2.1$"hint::English"[grep("\xd3", va16v2.1$"hint::English", useBytes=TRUE)]
va16v2.1$"hint::English"[grep("\xd4", va16v2.1$"hint::English", useBytes=TRUE)]
va16v2.1$"hint::English"[grep("\xd5", va16v2.1$"hint::English", useBytes=TRUE)]
va16v2.1$"hint::English"[grep("\xca", va16v2.1$"hint::English", useBytes=TRUE)]
va16v2.1$"hint::English"[grep("\"",   va16v2.1$"hint::English", useBytes=TRUE)]
va16v2.1$"label::English"[grep("\n", va16v2.1$"label..English", useBytes=TRUE)]

###### going to replace these with values that appear in the .xls file ######
###### NOTE: data.frame() changes the column names and converts string columns to factors
va16v2.1 <- data.frame(lapply(va16v2.1, function(x) { gsub("\xd2", "'", x)}))
va16v2.1 <- data.frame(lapply(va16v2.1, function(x) { gsub("\xd3", "'", x)}))
va16v2.1 <- data.frame(lapply(va16v2.1, function(x) { gsub("\xd4", "'", x)}))
va16v2.1 <- data.frame(lapply(va16v2.1, function(x) { gsub("\xd5", "'", x)}))
va16v2.1 <- data.frame(lapply(va16v2.1, function(x) { gsub("\xca", " ", x)}))
va16v2.1 <- data.frame(lapply(va16v2.1, function(x) { gsub("\"", "'", x)}))
va16v2.1 <- data.frame(lapply(va16v2.1, function(x) { gsub("\n", " ", x)}))
dim(va16v2.1)

levels(va16v2.1$hint..English)[grep("\xd2", levels(va16v2.1$hint..English), useBytes=TRUE)]
levels(va16v2.1$hint..English)[grep("\xd3", levels(va16v2.1$hint..English), useBytes=TRUE)]
levels(va16v2.1$hint..English)[grep("\xd4", levels(va16v2.1$hint..English), useBytes=TRUE)]
levels(va16v2.1$hint..English)[grep("\xd5", levels(va16v2.1$hint..English), useBytes=TRUE)]
levels(va16v2.1$hint..English)[grep("\xca", levels(va16v2.1$hint..English), useBytes=TRUE)]
levels(va16v2.1$hint..English)[grep("\"", levels(va16v2.1$hint..English), useBytes=TRUE)]
levels(va16v2.1$label..English)[grep("\n", levels(va16v2.1$label..English), useBytes=TRUE)]

#### second worksheet ####
va16v2.2.valid <- !is.na(rawVA16V2.2$"list name")
table(va16v2.2.valid)

va16v2.2 <- rawVA16V2.2[va16v2.2.valid,]
dim(va16v2.2)
dim(rawVA16V2.2)

names(va16v2.2)
va16v2.2$"label::English"[grep("\xd2", va16v2.2$"label::English", useBytes=TRUE)]
va16v2.2$"label::English"[grep("\xd3", va16v2.2$"label::English", useBytes=TRUE)]
va16v2.2$"label::English"[grep("\xd4", va16v2.2$"label::English", useBytes=TRUE)]
va16v2.2$"label::English"[grep("\xd5", va16v2.2$"label::English", useBytes=TRUE)]
va16v2.2$"label::English"[grep("\xca", va16v2.2$"label::English", useBytes=TRUE)]
va16v2.2$"label::English"[grep("\"", va16v2.2$"label::English", useBytes=TRUE)]
va16v2.2$"label::English"[grep("\n", va16v2.2$"label::English", useBytes=TRUE)]

###### going to replace these with values that appear in the .xls file ######
va16v2.2 <- data.frame(lapply(va16v2.2, function(x) { gsub("\xd5", "'", x)}))
va16v2.2 <- data.frame(lapply(va16v2.2, function(x) { gsub("\xca", " ", x)}))
dim(va16v2.2)

levels(va16v2.2$label..English)[grep("\xd5", levels(va16v2.2$label..English), useBytes=TRUE)]
levels(va16v2.2$label..English)[grep("\xca", levels(va16v2.2$label..English), useBytes=TRUE)]

###### clean "label..English" field (remove (Id###)  and [] ######
va16v2.1$label..English[1:20]
grep("^\\(Id.+\\) ", va16v2.1$label..English[1:20])
cbind(as.character(va16v2.1$label..English)[1:20], gsub("^\\(Id[^\\)]*\\)", "", va16v2.1$label..English[1:20]))
## tmp1 <- gsub("^\\(Id[^\\)]*\\)", "", va16v2.1$label..English)
tmp1 <- gsub("^\\([^\\)]*\\)", "", va16v2.1$label..English)
tmp2 <- str_trim(tmp1)
va16v2.1$label..English2 <- gsub("\\[(.*)\\]", "\\1", tmp2)
va16v2.1$label..English2
va16v2.1$label..English[12]
va16v2.1$label..English[556]
#--------------------------------------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------------------------------------#
## 2016 version 1 ##
#### first worksheet ####
va16v1.1.valid <- !is.na(rawVA16V1.1$name)
table(va16v1.1.valid)

va16v1.1 <- rawVA16V1.1[va16v1.1.valid,]
dim(va16v1.1)
dim(rawVA16V1.1)

###### add sequence number ######
va16v1.1$seq <- 1:nrow(va16v1.1)

###### some characters, e.g. ' and newline, are imported as markup code; examples... ######
va16v1.1$"hint::English"

va16v1.1$"hint::English"[grep("\xd2", va16v1.1$"hint::English", useBytes=TRUE)]
va16v1.1$"hint::English"[grep("\xd3", va16v1.1$"hint::English", useBytes=TRUE)]
va16v1.1$"hint::English"[grep("\xd4", va16v1.1$"hint::English", useBytes=TRUE)]
va16v1.1$"hint::English"[grep("\xd5", va16v1.1$"hint::English", useBytes=TRUE)]
va16v1.1$"hint::English"[grep("\xca", va16v1.1$"hint::English", useBytes=TRUE)]
va16v1.1$"hint::English"[grep("\"",   va16v1.1$"hint::English", useBytes=TRUE)]
va16v1.1$"label::English"[grep("\n",   va16v1.1$"label::English", useBytes=TRUE)]

###### going to replace these with values that appear in the .xls file ######
###### NOTE: data.frame() changes the column names and converts string columns to factors
va16v1.1 <- data.frame(lapply(va16v1.1, function(x) { gsub("\xd2", "'", x)}))
va16v1.1 <- data.frame(lapply(va16v1.1, function(x) { gsub("\xd3", "'", x)}))
va16v1.1 <- data.frame(lapply(va16v1.1, function(x) { gsub("\xd4", "'", x)}))
va16v1.1 <- data.frame(lapply(va16v1.1, function(x) { gsub("\xd5", "'", x)}))
va16v1.1 <- data.frame(lapply(va16v1.1, function(x) { gsub("\xca", " ", x)}))
va16v1.1 <- data.frame(lapply(va16v1.1, function(x) { gsub("\"", "'", x)}))
va16v1.1 <- data.frame(lapply(va16v1.1, function(x) { gsub("\n", "'", x)}))
dim(va16v1.1)

levels(va16v1.1$hint..English)[grep("\xd2", levels(va16v1.1$hint..English), useBytes=TRUE)]
levels(va16v1.1$hint..English)[grep("\xd3", levels(va16v1.1$hint..English), useBytes=TRUE)]
levels(va16v1.1$hint..English)[grep("\xd4", levels(va16v1.1$hint..English), useBytes=TRUE)]
levels(va16v1.1$hint..English)[grep("\xd5", levels(va16v1.1$hint..English), useBytes=TRUE)]
levels(va16v1.1$hint..English)[grep("\xca", levels(va16v1.1$hint..English), useBytes=TRUE)]
levels(va16v1.1$hint..English)[grep("\"", levels(va16v1.1$hint..English), useBytes=TRUE)]
levels(va16v1.1$label..English)[grep("\n",   levels(va16v1.1$label..English), useBytes=TRUE)]

#### second worksheet ####
va16v1.2.valid <- !is.na(rawVA16V1.2$"list name")
table(va16v1.2.valid)

va16v1.2 <- rawVA16V1.2[va16v1.2.valid,]
dim(va16v1.2)

names(va16v1.2)
va16v1.2$"label::English"[grep("\xd2", va16v1.2$"label::English", useBytes=TRUE)]
va16v1.2$"label::English"[grep("\xd3", va16v1.2$"label::English", useBytes=TRUE)]
va16v1.2$"label::English"[grep("\xd4", va16v1.2$"label::English", useBytes=TRUE)]
va16v1.2$"label::English"[grep("\xd5", va16v1.2$"label::English", useBytes=TRUE)]
va16v1.2$"label::English"[grep("\xca", va16v1.2$"label::English", useBytes=TRUE)]
va16v1.2$"label::English"[grep("\"", va16v1.2$"label::English", useBytes=TRUE)]
va16v1.2$"label::English"[grep("\n", va16v1.2$"label::English", useBytes=TRUE)]

###### going to replace these with values that appear in the .xls file ######
va16v1.2 <- data.frame(lapply(va16v1.2, function(x) { gsub("\xd5", "'", x)}))
dim(va16v1.2)
levels(va16v1.2$label..English)[grep("\xd5", levels(va16v1.2$label..English), useBytes=TRUE)]
#--------------------------------------------------------------------------------------------------------------------------------------#


#--------------------------------------------------------------------------------------------------------------------------------------#
# 3: BUILD OUTPUT TABLE CONTAINING COMPARISON & WRITE CSV FILE
#--------------------------------------------------------------------------------------------------------------------------------------#

# 3.1: Building table starting with questions appearing in the WHO 2016v2 questionnaire
#      (adding questions unique to other years below in 3.3, 3.4, and 3.5)
#

## First, create matches (if they exist) to other questionnaires ##
#### 2016 v2 & v1 -- just match on $name ####
table(is.na(match(as.character(va16v2.1$name), as.character(va16v1.1$name))))
va16v2.1$isMatch16 <- match(tolower(as.character(va16v2.1$name)), tolower(as.character(va16v1.1$name)))
table(is.na(va16v2.1$isMatch16))
va16v2.1$match16 <- as.character(va16v1.1$name[va16v2.1$isMatch16])

## COLUMN 1 -- $name
dim(va16v2.1)
out <- tolower(as.character(va16v2.1$name))
length(out)

## COLUMNS 2 through 45
out <- cbind(out, matrix(NA, nrow=length(out), ncol=11))
dim(out)

# 3.2: Go Through Questions in 2016
for(i in 1:nrow(va16v2.1)){

    ## COLUMNS 2-4: Diff name -- 2016v1
    nam16v2 <- as.character(va16v2.1$name[i])
    #### 2016v1
    cols2016v1_4 <- seq(2, 12, 2)
    if(is.na(va16v2.1$match16[i])) out[i,cols2016v1_4] <- "[no match found]"

    ## COLUMNS 3 & 4 -- Sequence Number, Diff Sequence 2016v1
    #### 2016v2
    seq16v2  <- as.character(va16v2.1$seq[i])
    out[i,3] <- seq16v2
    #### 2016v1
    seq16v1 <- as.character(va16v1.1$seq[match(va16v2.1$match16[i], as.character(va16v1.1$name))])
    seqSame <- seq16v2==seq16v1
    if(is.na(seqSame)) seqSame <- FALSE
    if(!seqSame){
        out[i,4] <- ifelse(is.na(seq16v2==seq16v1), "", seq16v1)
    }

    ## COLUMNS 5 & 6: Label -- 2016, Diff Label 2016v1
    lab16v2  <- as.character(va16v2.1$label..English2[i])
    out[i,5] <- ifelse(is.na(lab16v2), "[empty cell]", lab16v2)
    if(!is.na(lab16v2)){
        if(lab16v2=="") out[i,9] <- "[empty cell]"
    }
    #### 2016v1
    lab16v1 <- as.character(va16v1.1$label..English[match(va16v2.1$match16[i], as.character(va16v1.1$name))])
    labsame <- tolower(str_trim(lab16v2))==tolower(str_trim(lab16v1))
    if(is.na(labsame))                  labsame <- FALSE
    if(is.na(lab16v2) & is.na(lab16v1)) labsame <- TRUE
    if(!labsame){
        lab16v2w <- str_split(lab16v2, " ")[[1]]
        lab16v1w <- str_split(lab16v1, " ")[[1]]
        labmatch <- match(lab16v1w, lab16v2w)
        ###### capitalize differences in 2016v1
        lab16v1w2                  <- tolower(lab16v1w)
        lab16v1w2[is.na(labmatch)] <- toupper(lab16v1w2)[is.na(labmatch)]
        if(!is.na(va16v2.1$match16[i])) out[i,6] <- ifelse(is.na(lab16v1), "[empty cell]", str_c(lab16v1w2, collapse=" "))
    }

    ## COLUMNS 7 & 8: Type 2016v2; Diff Type 2016v1
    typ16v2   <- as.character(va16v2.1$type[i])
    hascho1   <- str_detect(typ16v2, pattern="select_one ")
    hascho2   <- str_detect(typ16v2, pattern="select_multiple ")
    hascho    <- hascho1 | hascho2
    out[i,7] <- typ16v2
    #### 2016v1
    typ16v1 <- as.character(va16v1.1$type[match(va16v2.1$match16[i], as.character(va16v1.1$name))])
    typSame <- typ16v2==typ16v1
    if(is.na(typSame)) typSame <- FALSE
    if(!typSame){
        typ16v2w <- str_split(typ16v2, " ")[[1]]
        typ16v1w <- str_split(typ16v1, " ")[[1]]
        typMatch <- match(typ16v1w, typ16v2w)
        ###### capitalize differences in 2016v1
        typ16v1w2                  <- tolower(typ16v1w)
        typ16v1w2[is.na(typMatch)] <- toupper(typ16v1w2)[is.na(typMatch)]
        if(!is.na(va16v2.1$match16[i])) out[i,8] <- ifelse(is.na(typ16v1), "[empty cell]", str_c(typ16v1w2, collapse=" "))
    }

    ## COLUMNS 9 & 10: Choices 2016v2; Diff Choices 2016v1
    ##                assuming that all needs for making choice are indicated by type=="select_one ..."
    t16v2   <- as.character(va16v2.1$type[i])
    hascho1 <- str_detect(t16v2, pattern="select_one ")
    hascho2 <- str_detect(t16v2, pattern="select_multiple ")
    hascho  <- hascho1 | hascho2
    if(hascho){
    #### list names
        cho16v2   <- ifelse(hascho1, gsub("(^select_one )(.*$)", "\\2", t16v2), gsub("(^select_multiple )(.*$)", "\\2", t16v2))
        out[i,9] <- tolower(cho16v2)
        ###### 2016v1
        t16v1   <- as.character(va16v1.1$type[match(as.character(va16v2.1$match16[i]), as.character(va16v1.1$name))])
        cho16v1 <- gsub("(^select_one )(.*$)", "\\2", t16v1)
        cho16v1 <- gsub("(^select_multiple )(.*$)", "\\2", t16v1)
        choSame <- cho16v2==cho16v1
        if(is.na(choSame)) choSame <- FALSE
        if(!choSame){
            cho16v2w <- str_split(str_trim(cho16v2), "_")[[1]]
            cho16v1w <- str_split(str_trim(cho16v1), "_")[[1]]
            choMatch <- match(cho16v1w, cho16v2w)
            ######## capitalize differences in 2016v1
            cho16v1w2                  <- tolower(cho16v1w)
            cho16v1w2[is.na(choMatch)] <- toupper(cho16v1w2)[is.na(choMatch)]
            if(!is.na(va16v2.1$match16[i])) out[i,10] <- ifelse(is.na(t16v1), "[empty cell]", str_c(cho16v1w2, collapse="_"))
        }

        ## COLUMNS 11 & 12: Labels 2016v2; Diff Labels 2016v1
        ###### labels
        chola16v2 <- as.character(va16v2.2$label..English[as.character(va16v2.2$list.name)%in%cho16v2])
        out[i,11] <- ifelse(length(chola16v2)==0, "[empty cell]", tolower(str_c(chola16v2, collapse="; ")))
        ######## 2016v1
        chola16v1 <- as.character(va16v1.2$label..English[as.character(va16v1.2$list.name)%in%cho16v1])
        ########## recoding "DK" to "Doesn't know" and "Ref" to "Refused to answer"
        chola16v1 <- gsub("DK", "Doesn't know", chola16v1)
        chola16v1 <- gsub("dk", "Doesn't know", chola16v1)
        chola16v1 <- gsub("Ref", "Refused to answer", chola16v1)
        if(!setequal(chola16v2, chola16v1)){
            choMatch <- match(chola16v1, chola16v2)
            ############ capitalize differences in 2016v1
            chola16v1w2                  <- tolower(chola16v1)
            chola16v1w2[is.na(choMatch)] <- toupper(chola16v1w2)[is.na(choMatch)]
            if(!is.na(va16v2.1$match16[i])) out[i,12] <- ifelse(length(chola16v1)==0, "[empty cell]", str_c(chola16v1w2, collapse="; "))
        }
    }
    ## ## COLUMNS 25-27: Hint; Diff Hint 2016v1; Diff Hint 2014
    ## hin16v2   <- as.character(va16v2.1$hint..English[i])
    ## out[i,25] <- ifelse(is.na(hin16v2), "[empty cell]", tolower(hin16v2))
    ## #### 2016v1
    ## hin16v1   <- as.character(va16v1.1$hint..English[match(va16v2.1$match16[i], as.character(va16v1.1$name))])
    ## hinSame   <- tolower(str_trim(hin16v2))==tolower(str_trim(hin16v1))
    ## if(is.na(hinSame))                  hinSame <- FALSE
    ## if(is.na(hin16v2) & is.na(hin16v1)) hinSame <- TRUE
    ## if(!hinSame){
    ##     hin16v2w <- str_split(str_trim(hin16v2), " ")[[1]]
    ##     hin16v1w <- str_split(str_trim(hin16v1), " ")[[1]]
    ##     hinMatch <- match(hin16v1w, hin16v2w)
    ##     ###### capitalize differences in 2016v1
    ##     hin16v1w2                  <- tolower(hin16v1w)
    ##     hin16v1w2[is.na(hinMatch)] <- toupper(hin16v1w2)[is.na(hinMatch)]
    ##     if(!is.na(va16v2.1$match16[i])) out[i,26] <- ifelse(is.na(hin16v1), "[empty cell]", str_c(hin16v1w2, collapse=" "))
    ## }
    ## #### 2014
    ## hin14   <- as.character(va14.1$hint..English[match(va16v2.1$match16[i], as.character(va14.1$name))])
    ## hinSame <- tolower(str_trim(hin16v2))==tolower(str_trim(hin14))
    ## if(is.na(hinSame))                hinSame <- FALSE
    ## if(is.na(hin16v2) & is.na(hin14)) hinSame <- TRUE
    ## if(!hinSame){
    ##     hin16v2w <- str_split(str_trim(hin16v2), " ")[[1]]
    ##     hin14w   <- str_split(str_trim(hin14), " ")[[1]]
    ##     hinMatch <- match(hin14w, hin16v2w)
    ##     ###### capitalize differences in 2014
    ##     hin14w2                  <- tolower(hin14w)
    ##     hin14w2[is.na(hinMatch)] <- toupper(hin14w2)[is.na(hinMatch)]
    ##     if(!is.na(va16v2.1$match14[i])) out[i,27] <- ifelse(is.na(hin14), "[empty cell]", str_c(hin14w2, collapse=" "))
    ##     }
    ## #### 2012 -- $hint..English  field is not included

    ## ## COLUMNS 28-30: Relevant 2016v2; Diff Relevant 2016v1; Diff Relevant 2014
    ## rel16v2   <- as.character(va16v2.1$relevant[i])
    ## out[i,28] <- ifelse(is.na(rel16v2), "", tolower(rel16v2))
    ## #### 2016v1
    ## rel16v1   <- as.character(va16v1.1$relevant[match(va16v2.1$match16[i], as.character(va16v1.1$name))])
    ## #### this one is different because the values may refer to other variables (which may change)
    ## hasid  <- str_detect(rel16v2, pattern="\\{")
    ## if(is.na(hasid)) hasid <- FALSE
    ## if(hasid){ ## assuming that all references to variables appear in {}
    ##     nvars  <- str_count(rel16v2, "\\{")
    ##     for(j in 1:nvars){
    ##         x      <- "[^\\{]*\\{"
    ##         xexp   <- paste("(^[^\\{]*\\{", str_c(rep(x,j-1), collapse=""), ")([^\\}]*)(\\}.*$)", sep="")
    ##         origid <- gsub(xexp, "\\2", rel16v2)
    ##         newid  <- as.character(va16v2.1$match16[as.character(va16v2.1$name)==origid])
    ##         if(length(newid)==0) newid <- NA
    ##         if(!is.na(newid)){
    ##             rel16v2  <- sub(origid, newid, rel16v2)
    ##         }
    ##         if(is.na(newid)){
    ##             rel16v2 <- sub(origid, "[no match found]", rel16v2)
    ##         }
    ##     }
    ## }
    ## relSame <- rel16v2==rel16v1
    ## if(is.na(relSame))                  relSame <- FALSE
    ## if(is.na(rel16v2) & is.na(rel16v1)) relSame <- TRUE
    ## if(!relSame){
    ##     rel16v2w  <- str_split(str_trim(rel16v2), " ")[[1]]
    ##     rel16v1w  <- str_split(str_trim(rel16v1), " ")[[1]]
    ##     relMatch  <- match(rel16v1w, rel16v2w)
    ##     ###### capitalize differences in 2014
    ##     rel16v1w2                   <- tolower(rel16v1w)
    ##     rel16v1w2[is.na(relMatch)]  <- toupper(rel16v1w2)[is.na(relMatch)]
    ##     if(!is.na(va16v2.1$match16[i])) out[i,29] <- ifelse(is.na(rel16v1), "[empty cell]", str_c(rel16v1w2, collapse=" "))
    ## }
    ## #### 2014
    ## rel14  <- as.character(va14.1$relevant[match(va16v2.1$match16[i], as.character(va14.1$name))])
    ## hasid  <- str_detect(rel16v2, pattern="\\{")
    ## if(is.na(hasid)) hasid <- FALSE
    ## if(hasid){ ## assuming that all references to variables appear in {}
    ##     nvars  <- str_count(rel16v2, "\\{")
    ##     for(j in 1:nvars){
    ##         x      <- "[^\\{]*\\{"
    ##         xexp   <- paste("(^[^\\{]*\\{", str_c(rep(x,j-1), collapse=""), ")([^\\}]*)(\\}.*$)", sep="")
    ##         origid <- gsub(xexp, "\\2", rel16v2)
    ##         newid  <- as.character(va16v2.1$match16[as.character(va16v2.1$name)==origid])
    ##         if(length(newid)==0) newid <- NA
    ##         if(!is.na(newid)){
    ##             rel16v2  <- sub(origid, newid, rel16v2)
    ##         }
    ##         if(is.na(newid)){
    ##             rel16v2 <- sub(origid, "[no match found]", rel16v2)
    ##         }
    ##     }
    ## }
    ## relSame <- rel16v2==rel14
    ## if(is.na(relSame))                relSame <- FALSE
    ## if(is.na(rel16v2) & is.na(rel14)) relSame <- TRUE
    ## if(!relSame){
    ##     rel16v2w  <- str_split(str_trim(rel16v2), " ")[[1]]
    ##     rel14w    <- str_split(str_trim(rel14), " ")[[1]]
    ##     relMatch  <- match(rel14w, rel16v2w)
    ##     ###### capitalize differences in 2014
    ##     rel14w2                   <- tolower(rel14w)
    ##     rel14w2[is.na(relMatch)]  <- toupper(rel14w2)[is.na(relMatch)]
    ##     if(!is.na(va16v2.1$match14[i])) out[i,30] <- ifelse(is.na(rel14), "[empty cell]", str_c(rel14w2, collapse=" "))
    ## }
    ## ## COLUMNS 31-33: Required 2016v2; Diff Required 2016v1; Diff Required 2014
    ## req16v2   <- as.character(va16v2.1$required[i])
    ## out[i,31] <- ifelse(is.na(rel16v2), "", tolower(rel16v2))
    ## #### 2016v1
    ## req16v1 <- as.character(va16v1.1$required[match(va16v2.1$match16[i], as.character(va16v1.1$name))])
    ## reqSame <- req16v2==req16v1
    ## if(is.na(reqSame))                  reqSame <- FALSE
    ## if(is.na(req16v2) & is.na(req16v1)) reqSame <- TRUE
    ## if(!reqSame){
    ##     if(!is.na(va16v2.1$match16[i])) out[i,32] <- ifelse(is.na(req16v1), "[empty cell]", toupper(req16v1))
    ## }
    ## #### 2014
    ## req14   <- as.character(va14.1$required[match(va16v2.1$match14[i], as.character(va14.1$name))])
    ## reqSame <- req16v2==req14
    ## if(is.na(reqSame))                reqSame <- FALSE
    ## if(is.na(req16v2) & is.na(req14)) reqSame <- TRUE
    ## if(!is.na(req16v2) & !is.na(req14)){
    ##     if(req16v2=="yes" & req14=="TRUE") reqSame <- TRUE
    ## }
    ## if(!reqSame){
    ##     if(!is.na(va16v2.1$match14[i])) out[i,33] <- ifelse(is.na(req14), "[empty cell]", toupper(req14))
    ## }

    ## ## COLUMNS 34-36: Appearance 2016v2; Diff Appearance 2016v1; Diff Appearance 2014
    ## app16v2    <- as.character(va16v2.1$appearance[i])
    ## out[i, 34] <- ifelse(is.na(app16v2), "", tolower(app16v2))
    ## #### 2016v1
    ## app16v1 <- as.character(va16v1.1$appearance[match(va16v2.1$match16[i], as.character(va16v1.1$name))])
    ## appSame <- app16v2==app16v1
    ## if(is.na(appSame))                  appSame <- FALSE
    ## if(is.na(app16v2) & is.na(app16v1)) appSame <- TRUE
    ## if(!appSame){
    ##     app16v2w <- str_split(str_trim(app16v2), " ")[[1]]
    ##     app16v1w <- str_split(str_trim(app16v1), " ")[[1]]
    ##     appMatch <- match(app16v1w, app16v2w)
    ##     ###### capitalize differences in 2016v1
    ##     app16v1w2                  <- tolower(app16v1w)
    ##     app16v1w2[is.na(appMatch)] <- toupper(app16v1w2)[is.na(appMatch)]
    ##     if(!is.na(va16v2.1$match16[i])) out[i,35] <- ifelse(is.na(app16v1), "[empty cell]", str_c(app16v1w2, collapse=" "))
    ## }
    ## #### 2014
    ## app14 <- as.character(va14.1$appearance[match(va16v2.1$match14[i], as.character(va14.1$name))])
    ## appSame <- app16v2==app14
    ## if(is.na(appSame))                appSame <- FALSE
    ## if(is.na(app16v2) & is.na(app14)) appSame <- TRUE
    ## if(!appSame){
    ##     app16v2w <- str_split(str_trim(app16v2), " ")[[1]]
    ##     app14w   <- str_split(str_trim(app14), " ")[[1]]
    ##     appMatch <- match(app14w, app16v2w)
    ##     ###### capitalize differences in 2014
    ##     app14w2                  <- tolower(app14w)
    ##     app14w2[is.na(appMatch)] <- toupper(app14w2)[is.na(appMatch)]
    ##     if(!is.na(va16v2.1$match14[i])) out[i,36] <- ifelse(is.na(app14), "[empty cell]", str_c(app14w2, collapse=" "))
    ## }

    ## ## COLUMNS 37-39: Calculation 2016v2; Diff Calculation 2016v1; Diff Calculation 2014
    ## calc16v2  <- as.character(va16v2.1$calculation[i])
    ## out[i,37] <- ifelse(is.na(calc16v2), "", tolower(calc16v2))
    ## ## 2016v1
    ## calc16v1 <- as.character(va16v1.1$calculation[match(va16v2.1$match16[i], as.character(va16v1.1$name))])
    ## #### this one is different because the values may refer to other variables (which may change)
    ## hasid  <- str_detect(calc16v2, pattern="\\{")
    ## if(is.na(hasid)) hasid <- FALSE
    ## if(hasid){ ## assuming that all references to variables appear in {}
    ##     nvars  <- str_count(calc16v2, "\\{")
    ##     for(j in 1:nvars){
    ##         x      <- "[^\\{]*\\{"
    ##         xexp   <- paste("(^[^\\{]*\\{", str_c(rep(x,j-1), collapse=""), ")([^\\}]*)(\\}.*$)", sep="")
    ##         origid <- gsub(xexp, "\\2", calc16v2)
    ##         newid  <- as.character(va16v2.1$match16[as.character(va16v2.1$name)==origid])
    ##         if(length(newid)==0) newid <- NA
    ##         if(!is.na(newid)){
    ##             calc16v2 <- sub(origid, newid, calc16v2)
    ##         }
    ##         if(is.na(newid)){
    ##             calc16v2 <- sub(origid, "[no match found]", calc16v2)
    ##         }
    ##     }
    ## }
    ## calcSame <- calc16v1==calc16v2
    ## if(is.na(calcSame))                   calcSame <- FALSE
    ## if(is.na(calc16v2) & is.na(calc16v1)) calcSame <- TRUE
    ## if(!calcSame){
    ##     calc16v2w <- str_split(str_trim(calc16v2), " ")[[1]]
    ##     calc16v1w <- str_split(str_trim(calc16v1), " ")[[1]]
    ##     calcMatch <- match(calc16v1w, calc16v2w)
    ##     ###### capitalize differences in 2016v1
    ##     calc16v1w2                   <- tolower(calc16v1w)
    ##     calc16v1w2[is.na(calcMatch)] <- toupper(calc16v1w2)[is.na(calcMatch)]
    ##     if(!is.na(va16v2.1$match16[i])) out[i,38] <- ifelse(is.na(calc16v1), "[empty cell]", str_c(calc16v1w2, collapse=" "))
    ## }
    ## ## 2014
    ## calc14 <- as.character(va14.1$calculation[match(va16v2.1$match14[i], as.character(va14.1$name))])
    ## #### this one is different because the values may refer to other variables (which may change)
    ## hasid  <- str_detect(calc16v2, pattern="\\{")
    ## if(is.na(hasid)) hasid <- FALSE
    ## if(hasid){ ## assuming that all references to variables appear in {}
    ##     nvars  <- str_count(calc16v2, "\\{")
    ##     for(j in 1:nvars){
    ##         x      <- "[^\\{]*\\{"
    ##         xexp   <- paste("(^[^\\{]*\\{", str_c(rep(x,j-1), collapse=""), ")([^\\}]*)(\\}.*$)", sep="")
    ##         origid <- gsub(xexp, "\\2", calc16v2)
    ##         newid  <- as.character(va16v2.1$match14[as.character(va16v2.1$name)==origid])
    ##         if(length(newid)==0) newid <- NA
    ##         if(!is.na(newid)){
    ##             calc16v2 <- sub(origid, newid, calc16v2)
    ##         }
    ##         if(is.na(newid)){
    ##             calc16v2 <- sub(origid, "[no match found]", calc16v2)
    ##         }
    ##     }
    ## }
    ## calcSame <- calc16v2==calc14
    ## if(is.na(calcSame))                 calcSame <- FALSE
    ## if(is.na(calc16v2) & is.na(calc14)) calcSame <- TRUE
    ## if(!calcSame){
    ##     calc16v2w <- str_split(str_trim(calc16v2), " ")[[1]]
    ##     calc14w   <- str_split(str_trim(calc14), " ")[[1]]
    ##     calcMatch <- match(calc14w, calc16v2w)
    ##     ###### capitalize differences in 2014
    ##     calc14w2                   <- tolower(calc14w)
    ##     calc14w2[is.na(calcMatch)] <- toupper(calc14w2)[is.na(calcMatch)]
    ##     if(!is.na(va16v2.1$match14[i])) out[i,39] <- ifelse(is.na(calc14), "[empty cell]", str_c(calc14w2, collapse=" "))
    ## }
    ## ## COLUMNS 40-42: Constraint 2016v2; Diff Constraint 2016v1; Diff Constraint 2014
    ## con16v2   <- as.character(va16v2.1$constraint[i])
    ## out[i,40] <- ifelse(is.na(con16v2), "", tolower(con16v2))
    ## #### 2016v1
    ## con16v1  <- as.character(va16v1.1$constraint[match(as.character(va16v2.1$match16[i]), as.character(va16v1.1$name))])
    ## conSame  <- con16v2==con16v1
    ## if(is.na(conSame))                  conSame <- FALSE
    ## if(is.na(con16v2) & is.na(con16v1)) conSame <- TRUE
    ## if(!conSame){
    ##     con16v2w    <- str_split(str_trim(con16v2), " ")[[1]]
    ##     con16v1w    <- str_split(str_trim(con16v1), " ")[[1]]
    ##     conMatch <- match(con16v1w, con16v2w)
    ##     ###### capitalize differences in 2016v1
    ##     con16v1w2                  <- tolower(con16v1w)
    ##     con16v1w2[is.na(conMatch)] <- toupper(con16v1w2)[is.na(conMatch)]
    ##     if(!is.na(va16v2.1$match16[i])) out[i,41] <- ifelse(is.na(con16v1), "[empty cell]", str_c(con16v1w2, collapse=" "))
    ## }
    ## #### 2014
    ## con14    <- as.character(va14.1$constraint[match(as.character(va16v2.1$match14[i]), as.character(va14.1$name))])
    ## conSame  <- con16v2==con14
    ## if(is.na(conSame))                conSame <- FALSE
    ## if(is.na(con16v2) & is.na(con14)) conSame <- TRUE
    ## if(!conSame){
    ##     con16v2w <- str_split(str_trim(con16v2), " ")[[1]]
    ##     con14w   <- str_split(str_trim(con14), " ")[[1]]
    ##     conMatch <- match(con14w, con16v2w)
    ##     ###### capitalize differences in 2014
    ##     con14w2                  <- tolower(con14w)
    ##     con14w2[is.na(conMatch)] <- toupper(con14w2)[is.na(conMatch)]
    ##     if(!is.na(va16v2.1$match14[i])) out[i,42] <- ifelse(is.na(con14), "[empty cell]", str_c(con14w2, collapse=" "))
    ## }

    ## ## COLUMNS 43-45: Constraint Message 2016v2; Diff Constraint Message 2016v1; Diff Constraint Message 2014
    ## mess16v2  <- as.character(va16v2.1$constraint_message..English[i])
    ## out[i,43] <- ifelse(is.na(mess16v2), "", tolower(mess16v2))
    ## #### 2016v1
    ## mess16v1 <- as.character(va16v1.1$constraint_message..English[match(as.character(va16v2.1$match16[i]), as.character(va16v1.1$name))])
    ## messSame <- mess16v2==mess16v1
    ## if(is.na(messSame))                   messSame <- FALSE
    ## if(is.na(mess16v2) & is.na(mess16v1)) messSame <- TRUE
    ## if(!messSame){
    ##     mess16v2w <- str_split(str_trim(mess16v2), " ")[[1]]
    ##     mess16v1w <- str_split(str_trim(mess16v1), " ")[[1]]
    ##     messMatch <- match(mess16v1w, mess16v2w)
    ##     ###### capitalize differences in 2016v1
    ##     mess16v1w2                   <- tolower(mess16v1w)
    ##     mess16v1w2[is.na(messMatch)] <- toupper(mess16v1w2)[is.na(messMatch)]
    ##     if(!is.na(va16v2.1$match16[i])) out[i,44] <- ifelse(is.na(mess16v1), "[empty cell]", str_c(mess16v1w2, collapse=" "))
    ## }
    ## #### 2014
    ## mess14 <- as.character(va14.1$constraint_message..English[match(as.character(va16v2.1$match14[i]), as.character(va14.1$name))])
    ## messSame <- mess16v2==mess14
    ## if(is.na(messSame))                 messSame <- FALSE
    ## if(is.na(mess16v2) & is.na(mess14)) messSame <- TRUE
    ## if(!messSame){
    ##     mess16v2w <- str_split(str_trim(mess16v2), " ")[[1]]
    ##     mess14w   <- str_split(str_trim(mess14), " ")[[1]]
    ##     messMatch <- match(mess14w, mess16v2w)
    ##     ###### capitalize differences in 2014
    ##     mess14w2                   <- tolower(mess14w)
    ##     mess14w2[is.na(messMatch)] <- toupper(mess14w2)[is.na(messMatch)]
    ##     if(!is.na(va16v2.1$match14[i])) out[i,45] <- ifelse(is.na(mess14), "[empty cell]", str_c(mess14w2, collapse=" "))
    ## }
}

# 3.3: Questions only asked in 2016v1
match(tolower(as.character(va16v1.1$name[i])), tolower(as.character(va16v2.1$name)))
for(i in 1:length(va16v1.1$name)){

    if(is.na(match(tolower(as.character(va16v1.1$name[i])), tolower(as.character(va16v2.1$name))))){

        t16v1    <- as.character(va16v1.1$type[i])
        hascho1  <- str_detect(t16v1, pattern="select_one ")
        hascho2  <- str_detect(t16v1, pattern="select_multiple ")
        hascho <- hascho1 | hascho2
        if(hascho){
            cho16v1    <- gsub("(^select_one )(.*$)", "\\2", t16v1)
            chola16v1  <- as.character(va16v1.2$label..English[as.character(va16v1.2$list.name)%in%cho16v1])
            chola16v1w <- str_c(chola16v1, collapse="; ")
        }
        if(!hascho){
            cho16v1    <- "[empty cell]"
            chola16v1w <- "[empty cell]"
        }
        out   <- rbind(out,
                       c("Not included in 2016v1_5", as.character(va16v1.1$name[i]),
                         "", va16v1.1$seq[i],
                         "", ifelse(is.na(va16v1.1$label..English[i]), "[empty cell]", as.character(va16v1.1$label..English[i])),
                         "", ifelse(is.na(va16v1.1$type[i]), "[empty cell]", as.character(va16v1.1$type[i])),
                         "", cho16v1,
                         "", chola16v1w#,
                         ## "", ifelse(is.na(va16v1.1$hint..English[i]), "[empty cell]", as.character(va16v1.1$hint..English[i])), "",
                         ## "", ifelse(is.na(va16v1.1$relevant[i]), "[empty cell]", as.character(va16v1.1$relevant[i])), "",
                         ## "", ifelse(is.na(va16v1.1$required[i]), "[empty cell]", as.character(va16v1.1$required[i])), "",
                         ## "", ifelse(is.na(va16v1.1$appearance[i]), "[empty cell]", as.character(va16v1.1$appearance[i])), "",
                         ## "", ifelse(is.na(va16v1.1$calculation[i]), "[empty cell]", as.character(va16v1.1$calculation[i])), "",
                         ## "", ifelse(is.na(va16v1.1$constraint[i]), "[empty cell]", as.character(va16v1.1$constraint[i])), "",
                         ## "", ifelse(is.na(va16v1.1$constraint_message..English[i]), "[empty cell]", as.character(va16v1.1$constraint_message..English[i])), ""
                         )
                       )
    }
}

# 3.6: Writes CSV file
dim(out)
colnames(out) <- c("Name -- 2016v1_5", "Diff Name -- 2016v1_4",
                   "Sequence Number -- 2016v1_5", "Sequence Number -- 2016v1_4",
                   "Label -- 2016v1_5", "Diff Label -- 2016v1_4",
                   "Type -- 2016v1_5", "Diff Type -- 2016v1_4",
                   "Choice Name -- 2016v1_5", "Diff Choice Name -- 2016v1_4",
                   "Choice Labels -- 2016v1_5", "Diff Choice Labels -- 2016v1_4"
                   )

write.csv(out, file="compWHO_v151_v141.csv", na="", row.names=FALSE)

#--------------------------------------------------------------------------------------------------------------------------------------#
#99: THAT'S ALL FOLKS
#--------------------------------------------------------------------------------------------------------------------------------------#
date()

