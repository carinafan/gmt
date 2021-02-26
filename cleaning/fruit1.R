# Fruit Clapping Task 1 

#---- set up ----

rm(list=ls())

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Fruit Task 1") %>% 
  as.data.frame()

# set column names
names = c(
  "user_id",
  "date",
  "duration",
  "non_pears_shown",
  "non_pears_correct",
  "pears_shown",
  "pears_correct"
)

# find each task start
started = which(df_raw$tag2 == "Started")

# number of starts
n = length(started)

# add 1 to end of start for subsetting last task start
started %<>% append(nrow(df_raw))

# set up empty dataframe
df = data.frame(matrix(data = NA, nrow = n, ncol = length(names)))
names(df) = names
df$date %<>% ymd()

#---- pull data ----

# for each task start...
for (i in 1:n) {
  
  # subset participant's rows
  range = (started[i]):(started[i+1]-1)
  raw_user_data = df_raw[range, ]
  
  # check that user ID matches throughout
  # if (raw_user_data %>% select(user_id) %>% unique() %>% nrow() == 1) {
  #   temp_id = raw_user_data$user_id[1]
  # } else {
  #   print("Error: multiple IDs")
  #   break
  # }
  
  # pull user ID
  temp_id = raw_user_data$user_id[1]
  
  # pull date
  temp_date = raw_user_data$created_at[1] %>% 
    date()
  
  # pull duration
  temp_duration = raw_user_data$created_at[1] %>% 
    interval(raw_user_data$created_at[nrow(raw_user_data)]) %>% 
    time_length("seconds")
  
  # pull non-pears
  temp_nonpears = raw_user_data %>% 
    filter(tag2 != "Started",
           tag2 != "pear",
           tag2 != "Game Ended")
  
  temp_nonpears_shown = temp_nonpears %>% 
    nrow()
  
  temp_nonpears_correct = temp_nonpears %>% 
    filter(tag3 == "correct") %>% 
    nrow()
  
  # pull pears
  temp_pears = raw_user_data %>% 
    filter(tag2 == "pear")
  
  temp_pears_shown = temp_pears %>% 
    nrow()
  
  temp_pears_correct = temp_pears %>% 
    filter(tag3 == "correct") %>% 
    nrow()
  
  # fill in daatframe
  df$user_id[i] = temp_id
  df$date[i] = temp_date
  df$duration[i] = temp_duration
  df$non_pears_shown[i] = temp_nonpears_shown
  df$non_pears_correct[i] = temp_nonpears_correct
  df$pears_shown[i] = temp_pears_shown
  df$pears_correct[i] = temp_pears_correct
  
}

#---- export clean data ----

df %>% 
  write.xlsx("../data/gmt_clean.xlsx",
             sheetName = "fruit1",
             row.names = FALSE,
             append = TRUE)

#---- data dictionary ----

# export column names
dict = names(df) %>%
  as.data.frame(stringsAsFactors = FALSE)
names(dict) = "column_label"

# add columns to describe the variables in each column
dict$description = NA
dict$type = NA
dict$value_range = NA

# fill in dictionary
for (i in 1:nrow(dict)) {
  switch(dict$column_label[i],

         "user_id" = {
           dict$description[i] = "user ID"
           dict$type[i] = "ID number"
           dict$value_range[i] = "NA"
         },

         "date" = {
           dict$description[i] = "date (yyyy-mm-dd)"
           dict$type[i] = "date"
           dict$value_range[i] = "NA"
         },
         
         "duration" = {
           dict$description[i] = "task duration in seconds"
           dict$type[i] = "integer"
           dict$value_range[i] = "anything greater than 0 and probably less than 200 ish"
         },
         
         "non_pears_shown" = {
           dict$description[i] = "number of fruits (not including pears) shown"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 54 (54 indicates a complete task)"
         },
         
         "non_pears_correct" = {
           dict$description[i] = "number of fruits (not included pears) responded to correctly"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 54"
         },
         
         "pears_shown" = {
           dict$description[i] = "number of pears shown"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 8 (8 indicates a complete task)"
         },
         
         "pears_correct" = {
           dict$description[i] = "number of pears where response was correctly withheld"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 8"
         }

         )
}

dict %>% 
  write.xlsx("../data/gmt_dictionary.xlsx",
             sheetName = "fruit1",
             row.names = FALSE,
             append = TRUE)

#---- clean up ----

rm(list=ls())