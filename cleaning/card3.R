# Card Sorting Task 3

#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Card Sorting Task 3") %>% 
  as.data.frame()

# set column names
names = c(
  "user_id",
  "date",
  "duration",
  "fives_shown",
  "fives_correct",
  "cards_shown",
  "cards_correct",
  "stops"
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
  
  # pull user ID
  temp_id = raw_user_data$user_id[1]
  
  # pull date
  temp_date = raw_user_data$created_at[1] %>% 
    date()
  
  # pull duration
  temp_duration = raw_user_data$created_at[1] %>% 
    interval(raw_user_data$created_at[nrow(raw_user_data)]) %>% 
    time_length("seconds")
  
  # pull fives
  temp_fives = raw_user_data$tag2 %>% 
    str_detect("five") %>% 
    sum()
  
  temp_fives_correct = (raw_user_data$tag3[str_detect(raw_user_data$tag2, "five")] == "Correct") %>% 
    sum()
  
  # pull all cards
  temp_cards = raw_user_data %>% 
    filter(tag3 == "Correct" |
             tag3 == "Incorrect") %>% 
    nrow()
  
  temp_cards_correct = raw_user_data %>% 
    filter(tag3 == "Correct") %>% 
    nrow()
  
  # pull stops
  temp_stops = raw_user_data %>% 
    filter(tag2 == "Stop Enacted") %>% 
    nrow()
  
  # fill in daatframe
  df$user_id[i] = temp_id
  df$date[i] = temp_date
  df$duration[i] = temp_duration
  df$fives_shown[i] = temp_fives
  df$fives_correct[i] = temp_fives_correct
  df$cards_shown[i] = temp_cards
  df$cards_correct[i] = temp_cards_correct
  df$stops[i] = temp_stops
  
}

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
         
         "fives_shown" = {
           dict$description[i] = "number of fives shown"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 4 (4 indicates a complete task)"
         },
         
         "fives_correct" = {
           dict$description[i] = "number of fives sorted correctly"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 4"
         },
         
         "cards_shown" = {
           dict$description[i] = "total number of cards (including fives) shown"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 52 (52 indicates a complete task)"
         },
         
         "cards_correct" = {
           dict$description[i] = "total numbers of cards (including fives) sorted correctly"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 52"
         },
         
         "stops" = {
           dict$description[i] = "number of stops enacted; participants are instructed to try to stop 4-6 times"
           dict$type[i] = "integer"
           dict$value_range[i] = "0 to 6 ish"
         }
         
  )
}

#---- clean up ----

df_card3 = df
dict_card3 = dict

rm(list= ls()[!(ls() %in% df_to_keep)])
