#--------------------------------------------------------------------------------------------------------------------------------------#
#  compPHMRC.R
#
#  created:        08/08/2017 -jt
#  last modified:  08/29/2017 -jt
#
#  Notes
#
#  (1) newlines (enter/return on keyboard; which appear as "\n") are replaced with " " (a space)
#
#  (2) UoM version of the questionnaire is phmrc12; PHMRC version is phmrc15
#
#  (3) order of the columns for the output file is changed at the end (before writing the output to a csv)
#
#  (4) to include commas in the data cells, the output file uses a semicolon ';' to separate columns
#      in MS Excel (on Mac OS X):  File --> Import --> CSV File (Import) --> Delimited (Next) --> Semicolon (Finish)
#
#--------------------------------------------------------------------------------------------------------------------------------------#

date()
#--------------------------------------------------------------------------------------------------------------------------------------#
#1: LOAD DATA & LIBRARIES
#--------------------------------------------------------------------------------------------------------------------------------------#
dir()
library(stringr)

dir()
## 2012
#### survrey
phmrc12  <- read.csv("SmartVA_PNG_v1.csv", na.string="", strip.white=TRUE)
dim(phmrc12)
names(phmrc12)

#### note: seemingly blank rows (e.g., 10 & 16) are included
phmrc12[10:25,]
table(is.na(phmrc12[10,]))

# replace '\n' with ' '
phmrc12 <- data.frame(lapply(phmrc12, function(x) { gsub("\\n", " ", x)}))

#### choices
phmrc12.2  <- read.csv("SmartVA_PNG_v1_2.csv", na.string="")
dim(phmrc12.2)
names(phmrc12.2)

## 2015 ##
phmrc15  <- read.csv("PHMRC_Shortened_Instrument_8_20_2015.csv", na.string="", strip.white=TRUE)
dim(phmrc15)
names(phmrc15)
#### note: seemingly blank rows (e.g., 10 & 14) are included
phmrc15[10:25,]
table(is.na(phmrc15[10,]))

# replace '\n' with ' '
phmrc15 <- data.frame(lapply(phmrc15, function(x) { gsub("\\n", " ", x)}))

phmrc15.2 <- read.csv("PHMRC_Shortened_Instrument_8_20_2015_2.csv", na.string="")
dim(phmrc15.2)
names(phmrc15.2)

#--------------------------------------------------------------------------------------------------------------------------------------#
# 2: CLEAN ORIGINAL DATA BY REMOVING BLANK LINES AND TYPE "END GROUP"
#--------------------------------------------------------------------------------------------------------------------------------------#

## 2012 names for questions in 2012
table(!is.na(phmrc12$name))
table(as.factor(phmrc12$type)!="end group" & !is.na(phmrc12$name))

V1valid <- as.factor(phmrc12$type)!="end group" & !is.na(phmrc12$name)
table(V1valid)

V1 <- phmrc12[V1valid,]
dim(V1)
dim(phmrc12)

## Looking for " ' `` but didn't find any
## grep('\\xd1', V2); grep('\\xd1', V2)

## 2015
table(!is.na(phmrc15$name))
table(as.factor(phmrc15$type)!="end group" & !is.na(phmrc15$name))

V2valid <- as.factor(phmrc15$type)!="end group" & !is.na(phmrc15$name)
table(V2valid)

V2 <- phmrc15[V2valid,]
dim(V2)
dim(phmrc15)

## List and count matches
dim(V1); dim(V2)
length(intersect(as.character(V1$name), as.character(V2$name)))
## there is actually one more match ("set form title" and "set form id" have the same name so they only get counted once)

table((unique(V1$name) %in% unique(V2$name)))
table((unique(V2$name) %in% unique(V2$name)))

#### vector identifying matches
V1match <- match(V2$name, V1$name)

## Differences
setdiff(V1$name, V2$name)

#--------------------------------------------------------------------------------------------------------------------------------------#
# 3: BUILD OUTPUT TABLE CONTAINING COMPARISON & WRITE CSV FILE
#--------------------------------------------------------------------------------------------------------------------------------------#

# 3.1: Building Table
## COLUMN 1 -- sequential number of names (this includes anything with a name -- "begin group", "add note prompt", and actual questions)
out <- 1:length(V2$name)
length(out)

## COLUMNS 2 & 3 -- Name -- PHMRC & Diff Name -- UoM
out <- cbind(as.character(out), as.character(V2$name), "")
dim(out)

## COLUMN 4 -- caption (label)
out <- cbind(out, as.character(V2$caption))
dim(out)
out[1:6,] ## HERE -- need to deal with newlines "\n"

## COLUMNS 5 through 3:34
V1row <- 1:length(V1$name)

dim(out)
out <- cbind(out, matrix(NA, nrow=nrow(out), ncol=30))
dim(out)

for(i in 1:nrow(V2)){

    ## deal with special cases: "set form title" & "set form id"
    ## otherwise they will be treated as different because the "name" does not match
    if(V2$type[i] %in% c("set form title", "set form id")){
        out[i, 5] <- ifelse(V1row[match(V2$type[i], V1$type)]==i, "", "[question deleted]")
        out[i, 3] <- as.character(V1$name[match(V2$type[i], V1$type)])
        next
    }

    ## handle questions asked ONLY in 2015 (and not in 2012)
    if(is.na(V1match[i])){
        out[i, 5] <- "[question deleted]"
        next
    }

    ## questions asked in BOTH years
    if(!is.na(V1match[i])){

        ## COLUMNS 5: Diff Sequential Number -- 2012 (don't think you need V1row)
        seqSame <- V1row[match(V2$name[i], V1$name)]==i
        if(!seqSame){
            out[i, 5] <- V1row[match(V2$name[i], V1$name)]
        }

        ## COLUMNS 6 & 7: Type -- 2015 & Diff Type -- 2012
        t15   <- as.character(V2$type[i])
        out[i, 6] <- tolower(t15)
        t12   <- as.character(V1$type[match(V2$name[i], V1$name)])
        tsame <- t15==t12
        if(is.na(tsame)) tsame <- FALSE

            if(!tsame){

                t15w   <- str_split(t15, " ")[[1]]
                t12w   <- str_split(t12, " ")[[1]]
                tmatch <- match(t12w, t15w)

                ###### capitalize differences in 2012
                t12w2                <- tolower(t12w)
                t12w2[is.na(tmatch)] <- toupper(t12w2)[is.na(tmatch)]

                out[i, 7] <- ifelse(is.na(t12), "[empty cell]", str_c(t12w2, collapse=" "))
            }

        ## COLUMNS 8: Diff Caption -- 2012
        cap15   <- as.character(V2$caption[i])
        cap12   <- as.character(V1$caption..English[match(V2$name[i], V1$name)])
        capsame <- tolower(str_trim(cap15))==tolower(str_trim(cap12))

        if(is.na(capsame))              capsame <- FALSE
        if(is.na(cap15) & is.na(cap12)) capsame <- TRUE

        if(!capsame){

            cap15w   <- str_split(cap15, " ")[[1]]
            cap12w   <- str_split(cap12, " ")[[1]]
            capmatch <- match(cap12w, cap15w)

            ###### capitalize differences in 2012
            cap12w2                  <- tolower(cap12w)
            cap12w2[is.na(capmatch)] <- toupper(cap12w2)[is.na(capmatch)]

            out[i, 8] <- ifelse(is.na(cap12), "[empty cell]", str_c(cap12w2, collapse=" "))
        }

        ## COLUMNS 9 & 10: Required -- 2015 & Diff Required -- 2012
        req15   <- as.character(V2$required[i])
        out[i, 9] <- ifelse(is.na(req15), "", tolower(req15))
        req12   <- as.character(V1$required[match(V2$name[i], V1$name)])
        reqsame <- req12==req15
        if(is.na(reqsame))               reqsame <- FALSE
        if(is.na(req12) & is.na(req15))  reqsame <- TRUE

        if(!reqsame){

            req15w   <- str_split(str_trim(req15), " ")[[1]]
            req12w   <- str_split(str_trim(req12), " ")[[1]]
            reqmatch <- match(req12w, req15w)

            ###### capitalize differences in 2014
            req12w2                  <- tolower(req12w)
            req12w2[is.na(reqmatch)] <- toupper(req12w2)[is.na(reqmatch)]

            out[i, 10] <- ifelse(is.na(req12), "[empty cell]", str_c(req12w2, collapse=" "))
        }

        ## COLUMNS 11 & 12: Appearance -- 2016 & Diff Appearance -- 2012
        app15   <- as.character(V2$appearance[i])
        out[i, 11] <- ifelse(is.na(app15), "", tolower(app15))
        app12   <- as.character(V1$appearance[match(V2$name[i], V1$name)])
        appsame <- app12==app15
        if(is.na(appsame))              appsame <- FALSE
        if(is.na(app12) & is.na(app15)) appsame <- TRUE

        if(!appsame){

            app15w    <- str_split(str_trim(app15), " ")[[1]]
            app12w    <- str_split(str_trim(app12), " ")[[1]]
            appmatch2 <- match(app12w, app15w)

            ###### capitalize differences in 2014
            app12w2                   <- tolower(app12w)
            app12w2[is.na(appmatch2)] <- toupper(app12w2)[is.na(appmatch2)]


            out[i, 12] <- ifelse(is.na(app12), "[empty cell]", str_c(app12w2, collapse=" "))
        }

        ## COLUMNS 13 & 14: Constraint -- 2015 & Diff Constraint -- 2012
        con15   <- as.character(V2$constraint[i])
        out[i, 13] <- ifelse(is.na(con15), "", tolower(con15))
        con12   <- as.character(V1$constraint[match(V2$name[i], V1$name)])
        consame <- con12==con15
        if(is.na(consame))              consame <- FALSE
        if(is.na(con12) & is.na(con15)) consame <- TRUE

        if(!consame){

            con15w   <- str_split(str_trim(con15), " ")[[1]]
            con12w   <- str_split(str_trim(con12), " ")[[1]]
            conmatch <- match(con12w, con15w)

            ###### capitalize differences in 2014
            con12w2                  <- tolower(con12w)
            con12w2[is.na(conmatch)] <- toupper(con12w2)[is.na(conmatch)]

            out[i, 14] <- ifelse(is.na(con12), "[empty cell]", str_c(con12w2, collapse=" "))
        }

        ## COLUMNS 15 & 16: Constraint message -- 2015 & Diff Constraint message -- 2012
        conMess15  <- as.character(V2$constraint_message[i])
        out[i, 15] <- ifelse(is.na(conMess15), "", tolower(conMess15))
        conMess12  <- as.character(V1$constraint_message..English[match(V2$name[i], V1$name)])
        ## if(length(conMess15)==0) conMess15 <- NA
        ## if(length(conMess12)==0) conMess12 <- NA

        conMessSame <- str_trim(conMess12)==str_trim(conMess15)
        if(is.na(conMessSame))                  conMessSame <- FALSE
        if(is.na(conMess12) & is.na(conMess15)) conMessSame <- TRUE

        if(!conMessSame){

            conMess15w   <- str_split(str_trim(conMess15), " ")[[1]]
            conMess12w   <- str_split(str_trim(conMess12), " ")[[1]]
            conMessMatch <- match(conMess12w, conMess15w)

            ###### capitalize differences in 2012
            conMess12w2                      <- tolower(conMess12w)
            conMess12w2[is.na(conMessMatch)] <- toupper(conMess12w2)[is.na(conMessMatch)]

            out[i, 16] <- ifelse(is.na(conMess12), "[empty cell]", str_c(conMess12w2, collapse=" "))

        }

        ## COLUMNS 17 & 18: Relevance -- 2015 & Diff Relevance -- 2012
        rel15  <- as.character(V2$relevance[i])
        out[i, 17] <- ifelse(is.na(rel15), "", tolower(rel15))

        rel12  <- as.character(V1$relevance[match(V2$name[i], V1$name)])

        relSame <- str_trim(rel12)==str_trim(rel15)
        if(is.na(relSame))              relSame <- FALSE
        if(is.na(rel12) & is.na(rel15)) relSame <- TRUE

        if(!relSame){

            rel15w   <- str_split(str_trim(rel15), " ")[[1]]
            rel12w   <- str_split(str_trim(rel12), " ")[[1]]
            relMatch <- match(rel12w, rel15w)

            ###### capitalize differences in 2012
            rel12w2                  <- tolower(rel12w)
            rel12w2[is.na(relMatch)] <- toupper(rel12w2)[is.na(relMatch)]

            out[i, 18] <- ifelse(is.na(rel12), "[empty cell]", str_c(rel12w2, collapse=" "))

        }

        ## COLUMNS 19 & 20: Calculation -- 2015 & Diff Calculation -- 2012
        cal15  <- as.character(V2$calculation[i])
        out[i, 19] <- ifelse(is.na(cal15), "", tolower(cal15))

        cal12  <- as.character(V1$calculation[match(V2$name[i], V1$name)])

        calSame <- str_trim(cal12)==str_trim(cal15)
        if(is.na(calSame))              calSame <- FALSE
        if(is.na(cal12) & is.na(cal15)) calSame <- TRUE

        if(!calSame){

            cal15w   <- str_split(str_trim(cal15), " ")[[1]]
            cal12w   <- str_split(str_trim(cal12), " ")[[1]]
            calMatch <- match(cal12w, cal15w)

            ###### capitalize differences in 2012
            cal12w2                  <- tolower(cal12w)
            cal12w2[is.na(calMatch)] <- toupper(cal12w2)[is.na(calMatch)]

            out[i, 20] <- ifelse(is.na(cal12), "[empty cell]", str_c(cal12w2, collapse=" "))

        }

        ## COLUMNS 21 & 22: Image -- 2015 & Diff Image -- 2012
        ima15  <- as.character(V2$image[i])
        out[i, 21] <- ifelse(is.na(ima15), "", tolower(ima15))

        ima12  <- as.character(V1$image..English[match(V2$name[i], V1$name)])

        imaSame <- str_trim(ima12)==str_trim(ima15)
        if(is.na(imaSame))              imaSame <- FALSE
        if(is.na(ima12) & is.na(ima15)) imaSame <- TRUE

        if(!imaSame){

            ima15w   <- str_split(str_trim(ima15), " ")[[1]]
            ima12w   <- str_split(str_trim(ima12), " ")[[1]]
            imaMatch <- match(ima12w, ima15w)

            ###### capitalize differences in 2012
            ima12w2                  <- tolower(ima12w)
            ima12w2[is.na(imaMatch)] <- toupper(ima12w2)[is.na(imaMatch)]

            out[i, 22] <- ifelse(is.na(ima12), "[empty cell]", str_c(ima12w2, collapse=" "))

        }

        ## COLUMNS 23 & 24: Audio -- 2015 & Diff Audio -- 2012
        aud15  <- as.character(V2$audio[i])
        out[i, 23] <- ifelse(is.na(aud15), "", tolower(aud15))

        aud12  <- as.character(V1$audio..English[match(V2$name[i], V1$name)])

        audSame <- str_trim(aud12)==str_trim(aud15)
        if(is.na(audSame))              audSame <- FALSE
        if(is.na(aud12) & is.na(aud15)) audSame <- TRUE

        if(!audSame){

            aud15w   <- str_split(str_trim(aud15), " ")[[1]]
            aud12w   <- str_split(str_trim(aud12), " ")[[1]]
            audMatch <- match(aud12w, aud15w)

            ###### capitalize differences in 2012
            aud12w2                  <- tolower(aud12w)
            aud12w2[is.na(audMatch)] <- toupper(aud12w2)[is.na(audMatch)]

            out[i, 24] <- ifelse(is.na(aud12), "[empty cell]", str_c(aud12w2, collapse=" "))

        }

        ## COLUMNS 25 & 26: Hint -- 2015 & Diff Hint -- 2012
        hin15  <- as.character(V2$hint[i])
        out[i, 25] <- ifelse(is.na(hin15), "", tolower(hin15))

        hin12  <- as.character(V1$hint..English[match(V2$name[i], V1$name)])

        hinSame <- str_trim(hin12)==str_trim(hin15)
        if(is.na(hinSame))              hinSame <- FALSE
        if(is.na(hin12) & is.na(hin15)) hinSame <- TRUE

        if(!hinSame){

            hin15w   <- str_split(str_trim(hin15), " ")[[1]]
            hin12w   <- str_split(str_trim(hin12), " ")[[1]]
            hinMatch <- match(hin12w, hin15w)

            ###### capitalize differences in 2012
            hin12w2                  <- tolower(hin12w)
            hin12w2[is.na(hinMatch)] <- toupper(hin12w2)[is.na(hinMatch)]

            out[i, 26] <- ifelse(is.na(hin12), "[empty cell]", str_c(hin12w2, collapse=" "))

        }

        ## CHOICES (columns 27 -- 34)
        #### assuming that all needs for making choice are indicated by type=="add select select one prompt using..."
        t15     <- as.character(V2$type[i])
        hasLNam <- str_detect(t15, pattern="add select")

        if(hasLNam){

            ## COLUMNS 27 & 28: list_name -- 2015 & Diff list_name -- 2012
            multipleTag15 <- grep('multiple', V2$type[i])
            if(length(multipleTag15)==0) lNam15 <- gsub("(^add select one prompt using )(.*$)", "\\2", t15)
            if(length(multipleTag15)==1) lNam15 <- gsub("(^add select multiple prompt using )(.*$)", "\\2", t15)

            out[i, 27] <- tolower(lNam15)

            ######## 2012
            t12      <- as.character(V1$type[match(V2$name[i], V1$name)])
            multipleTag12 <- grep('multiple', t12)
            if(length(multipleTag12)==0) lNam12 <- gsub("(^add select one prompt using )(.*$)", "\\2", t12)
            if(length(multipleTag12)==1) lNam12 <- gsub("(^add select multiple prompt using )(.*$)", "\\2", t12)

            lNamsame <- lNam12==lNam15
            if(is.na(lNamsame)) lNamsame <- FALSE

            if(!lNamsame){

                lNam15w   <- str_split(str_trim(lNam15), "")[[1]]
                lNam12w   <- str_split(str_trim(lNam12), "")[[1]]
                lNammatch <- match(lNam12w, lNam15w)

                ###### capitalize differences in 2014
                lNam12w2                   <- tolower(lNam12w)
                lNam12w2[is.na(lNammatch)] <- toupper(lNam12w2)[is.na(lNammatch)]

                out[i, 28] <- ifelse(is.na(lNam12), "[empty cell]", str_c(lNam12w2, collapse=""))
            }

            ###### COLUMNS 29 & 30: Name -- 2015 & Diff Name -- 2012
            nam15 <- as.character(phmrc15.2$name[as.character(phmrc15.2$list_name)%in%lNam15])
            out[i, 29] <- ifelse(length(nam15)==0, "", tolower(str_c(nam15, collapse="; ")))

            ######## 2012
            nam12 <- as.character(phmrc12.2$name[as.character(phmrc12.2$list_name)%in%lNam12])

            if(!setequal(nam12, nam15)){

                namMatch <- match(nam12, nam15)

                ###### capitalize differences in 2014
                nam12w                  <- tolower(nam12)
                nam12w[is.na(namMatch)] <- toupper(nam12w)[is.na(namMatch)]

                out[i, 30] <- ifelse(length(nam12)==0, "[empty cell]", str_c(nam12w, collapse="; "))
            }

            ###### COLUMNS 31 & 32: Label -- 2015 & Diff Label -- 2012
            lab15 <- as.character(phmrc15.2$label[as.character(phmrc15.2$list_name)%in%lNam15])
            out[i, 31] <- ifelse(length(lab15)==0, "", tolower(str_c(lab15, collapse="; ")))

            ######## 2012
            lab12 <- as.character(phmrc12.2$label..English[as.character(phmrc12.2$list_name)%in%lNam12])

            if(!setequal(lab12, lab15)){

                labMatch <- match(lab12, lab15)

                ###### capitalize differences in 2014
                lab12w                  <- tolower(lab12)
                lab12w[is.na(labMatch)] <- toupper(lab12w)[is.na(labMatch)]

                out[i, 32] <- ifelse(length(lab12)==0, "[empty cell]", str_c(lab12w, collapse="; "))
            }

            ###### COLUMNS 33 & 34: Image -- 2015 & Diff Image -- 2012
            ima15 <- as.character(phmrc15.2$image[as.character(phmrc15.2$list_name)%in%lNam15])
            out[i, 33] <- ifelse(all(is.na(ima15)), "", tolower(str_c(ima15, collapse="; ")))
            if(all(is.na(ima15))) ima15 <- ""

            ######## 2012
            ima12 <- as.character(phmrc12.2$image..English[as.character(phmrc12.2$list_name)%in%lNam12])
            if(length(ima12)==0) ima12 <- ""

            if(!setequal(ima12, ima15)){

                imaMatch <- match(ima12, ima15)

                ###### capitalize differences in 2014
                ima12w                  <- tolower(ima12)
                ima12w[is.na(imaMatch)] <- toupper(ima12w)[is.na(imaMatch)]

                out[i, 34] <- ifelse(length(ima12)==0, "[empty cell]", str_c(ima12w, collapse="; "))
            }
        }
    }
}

# 3.3: Questions only asked in 2012
for(i in 1:length(V1$name)){

    if(V1$type[i] %in% c("set form title", "set form id")){
        next
    }

    if(is.na(match(V1$name[i], V2$name))){

        V1nam <- ifelse(length(V1$name[i])==0, "", as.character(V1$name[i]))
        V1typ <- ifelse(length(V1$type[i])==0, "", as.character(V1$type[i]))
        V1lab <- ifelse(length(V1$caption..English[i])==0, "", as.character(V1$caption..English[i]))

        t12     <- as.character(V1$type[i])
        hasLNam <- str_detect(t12, pattern="add select")
        lNam12  <- ""; nam12w <- ""; lab12w <- ""; ima12w <- ""

        if(hasLNam){

            multipleTag12 <- grep('multiple', t12)
            if(length(multipleTag12)==0) lNam12 <- gsub("(^add select one prompt using )(.*$)", "\\2", t12)
            if(length(multipleTag12)==1) lNam12 <- gsub("(^add select multiple prompt using )(.*$)", "\\2", t12)

            nam12  <- as.character(phmrc12.2$name[as.character(phmrc12.2$list_name)%in%lNam12])
            nam12w <- str_c(nam12, collapse="; ")

            lab12  <- as.character(phmrc12.2$label..English[as.character(phmrc12.2$list_name)%in%lNam12])
            lab12w <- str_c(lab12, collapse="; ")

            ima12  <- as.character(phmrc12.2$image..English[as.character(phmrc12.2$list_name)%in%lNam12])
            ima12w <- str_c(ima12, collapse="; ")
            }


        out   <- rbind(out, c("Not included in PHMRC", "[empty cell]", V1nam, "[empty cell]", V1row[i],
                              "[empty cell]", V1typ,
                              V1lab,
                              ifelse(is.na(V1$required[i]), "", "[empty cell]"), V1$required[i],
                              ifelse(is.na(V1$appearance[i]), "", "[empty cell]"), V1$appearance[i],
                              ifelse(is.na(V1$constraint[i]), "", "[empty cell]"), V1$constraint[i],
                              ifelse(is.na(V1$constraint_message..English[i]), "", "[empty cell]"), V1$constraint_message..English[i],
                              ifelse(is.na(V1$relevance[i]), "", "[empty cell]"), V1$relevance[i],
                              ifelse(is.na(V1$calculation[i]), "", "[empty cell]"), V1$calculation[i],
                              ifelse(is.na(V1$image..English[i]), "", "[empty cell]"), V1$image..English[i],
                              ifelse(is.na(V1$audio..English[i]), "", "[empty cell]"), V1$audio..English[i],
                              ifelse(is.na(V1$hint..English[i]), "", "[empty cell]"), V1$hint..English[i],
                              ifelse(lNam12=="", "", "[empty cell]"), lNam12,
                              ifelse(nam12w=="", "", "[empty cell]"), nam12w,
                              ifelse(lab12w=="", "", "[empty cell]"), lab12w,
                              ifelse(ima12w=="", "", "[empty cell]"), ima12w)
                       )
    }
}


# 3.5: Writes CSV file
dim(out)

## colnames(out) <- c("Sequential Number -- PHMRC", "Name -- PHMRC", "Caption -- PHMRC",
##                    "Sequential Number -- UoM",
##                    "Type -- PHMRC", "Diff Type -- UoM",
##                    "Diff Caption -- UoM",
##                    "Required -- PHMRC", "Diff Required -- UoM",
##                    "Appearance -- PHMRC", "Diff Appearance -- UoM",
##                    "Constraint -- PHMRC", "Diff Constraint -- UoM",
##                    "Constraint Message -- PHMRC", "Diff Constraint Message -- UoM",
##                    "Relevance -- PHMRC", "Diff Relevance -- UoM",
##                    "Calculation -- PHMRC", "Diff Calculation -- UoM",
##                    "Image -- PHMRC", "Diff Image -- UoM",
##                    "Audio -- PHMRC", "Diff Audio -- UoM",
##                    "Hint -- PHMRC", "Diff Hint -- UoM",
##                    "Choices -- PHMRC", "Diff Choices -- UoM",
##                    "Choices Name -- PHMRC", "Diff Choices Name -- UoM",
##                    "Choices Label -- PHMRC", "Diff Choices Label -- UoM",
##                    "Choices Image -- PHMRC", "Diff Choices Image -- UoM")

out2 <- out[,c(1,5,2,3,4,8,6,7,9:34)]
colnames(out2) <- c("Sequential Number -- PHMRC", "Diff Sequential Number -- UoM",
                    "Name -- PHMRC", "Diff Name -- UoM",
                    "Caption -- PHMRC", "Diff Caption -- UoM",
                    "Type -- PHMRC", "Diff Type -- UoM",
                    "Required -- PHMRC", "Diff Required -- UoM",
                    "Appearance -- PHMRC", "Diff Appearance -- UoM",
                    "Constraint -- PHMRC", "Diff Constraint -- UoM",
                    "Constraint Message -- PHMRC", "Diff Constraint Message -- UoM",
                    "Relevance -- PHMRC", "Diff Relevance -- UoM",
                    "Calculation -- PHMRC", "Diff Calculation -- UoM",
                    "Image -- PHMRC", "Diff Image -- UoM",
                    "Audio -- PHMRC", "Diff Audio -- UoM",
                    "Hint -- PHMRC", "Diff Hint -- UoM",
                    "Choices -- PHMRC", "Diff Choices -- UoM",
                    "Choices Name -- PHMRC", "Diff Choices Name -- UoM",
                    "Choices Label -- PHMRC", "Diff Choices Label -- UoM",
                    "Choices Image -- PHMRC", "Diff Choices Image -- UoM")


write.csv2(out2, file="compPHMRC.csv", na="", row.names=FALSE)


#--------------------------------------------------------------------------------------------------------------------------------------#
#99: THAT'S ALL FOLKS
#--------------------------------------------------------------------------------------------------------------------------------------#
date()

