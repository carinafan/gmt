# Complex Tasks 2

#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Complex Task 2") %>% 
  as.data.frame()

# set column names
names = c("user_id",
          "date",
          "order",
          "task",
          "number_done",
          "number_correct",
          "score",
          "stops",
          "duration")

# set task names
tasks = c("Card Sorting",
          "Name Sorting",
          "Dot to Dot",
          "Spot Difference",
          "Word Search")

# find each task starts
df_raw %<>% filter(! tag2 == "Game Started")
started = which(df_raw$tag2 == "Started")

# number of starts
n = length(started)

# add 1 to end of start for subsetting last task start
started %<>% append(nrow(df_raw))

# set up empty dataframe
df = data.frame(matrix(data = NA, nrow = 0, ncol = length(names)))
names(df) = names
df$date %<>% ymd()

#---- pull data ----

# for each task start...
for (i in 1:n) {
  
  # subset participant's rows
  range = (started[i]):(started[i+1]-1)
  raw_user_data = df_raw[range, ]
  
  # find task switches
  switches = 1 %>% # set the first row for subsetting
    append(which(raw_user_data$tag2 == "Task Switch")) %>% 
    append(which(raw_user_data$tag2 == "Game Ended")[1])
  
  # if there isn't a "Game Ended" section at the end, add an empty placeholder row
  if (is.na(switches[length(switches)])) {
    raw_user_data %<>% rbind(rep(NA, 7))
    switches[length(switches)] = nrow(raw_user_data)
  }
  
  # set up participant dataframe
  temp_df = matrix(data = NA, nrow = length(switches) - 1, ncol = length(names)) %>%
    data.frame()

  names(temp_df) = names

  # fill in task data

  for (s in 1:(length(switches) - 1)) {

    # subset task rows
    task_range = (switches[s]:(switches[s+1]-1))
    raw_task_data = raw_user_data[task_range, ]
    
    # check for task name
    temp_task_rows = raw_task_data %>% 
      filter(tag2 %in% tasks) %>% 
      select(tag2)
    
    # if there is only 1 task name present, pull scores
    if (nrow(temp_task_rows) == 1) {
      
      # pull task name
      if (temp_task_rows$tag2 == "Name Sorting") {
        temp_task = "Birthdate Sorting"
      } else if (temp_task_rows$tag2 == "Card Sorting") {
        temp_task = "Card Sorting"
      } else if (temp_task_rows$tag2 == "Dot to Dot") {
        temp_task = "Dot to Dot"
      } else if (temp_task_rows$tag2 == "Word Search") {
        temp_task = "Word Search"
      } else if (temp_task_rows$tag2 == "Spot Difference") {
        temp_task = "Spot Difference"
      }
      
      # pull task scores
      if (temp_task == "Birthdate Sorting") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("Item Moved. Score is:", tag2)) %>% 
          nrow()
        
        temp_number_correct = NA
        
        temp_score = raw_task_data %>% 
          filter(grepl("Item Moved. Score is:", tag2)) %>% 
          select(tag3) %>% 
          slice(temp_number_done) %>% 
          pull()
        
        if (identical(temp_score, character(0))) {
          temp_score = NA
        }
        
      } else if (temp_task == "Card Sorting") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("card sorted", tag2)) %>% 
          nrow()
        
        temp_number_correct = raw_task_data %>% 
          filter(grepl("card sorted: correct", tag2)) %>% 
          nrow()
        
        temp_score = raw_task_data$tag3[tail(which(raw_task_data$tag2 == "Card sorted. Score is:"), 1)]
        
        if (identical(temp_score, character(0))) {
          temp_score = NA
        }
        
      } else if (temp_task == "Dot to Dot") {
        
        # temp_number_done = raw_task_data %>% 
        #   filter(grepl("Dot Connected", tag2)) %>% 
        #   nrow()
        
        temp_number_done = NA
        
        temp_number_correct = NA
        
        temp_score = NA
        
      } else if (temp_task == "Word Search") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("Word Found:", tag2)) %>% 
          nrow()
        
        temp_number_correct = NA
        
        temp_score = NA
        
      } else if (temp_task == "Spot Difference") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("Different Found", tag2)) %>% 
          nrow()
        
        temp_number_correct = NA
        
        temp_score = NA
        
      }
      
    } else { # otherwise put NAs, to be filled manually
      
      temp_task = NA
      temp_number_done = NA
      temp_number_correct = NA
      temp_score = NA
      
    }
    
    # pull stops
    task_stops = raw_task_data %>% 
      filter(tag2 == "Stop Sounded") %>% 
      nrow()
    
    # pull duration
    ## if there's a Task Switch or Game Ended row following the task, then calculate duration up to that row
    ## if not, calculate duration up to the last trial of the current task
    if (!is.na(raw_user_data$created_at[switches[s+1]])) {
      
      task_duration = raw_user_data$created_at[switches[s]] %>% 
        interval(raw_user_data$created_at[switches[s+1]]) %>% 
        time_length("seconds")
      
    } else {
      
      task_duration = raw_task_data$created_at[1] %>%
        interval(raw_task_data$created_at[nrow(raw_task_data)]) %>%
        time_length("seconds")
      
    }

    # fill in participant dataframe
    temp_df$task[s] = temp_task
    temp_df$duration[s] = task_duration
    temp_df$number_done[s] = temp_number_done
    temp_df$number_correct[s] = temp_number_correct
    temp_df$score[s] = temp_score
    temp_df$stops[s] = task_stops
    
  }

  # fill in remaining info
  temp_df$user_id = raw_user_data$user_id[1]
  temp_df$date = raw_user_data$created_at[1]
  temp_df$order = seq(1:(length(switches) - 1))
  
  # append participant dataframe to overall dataframe
  df %<>% rbind(temp_df)
} 

#---- hard code fixes ----

df$task[28] = "Card Sorting"
df$number_done[28] = 16
df$score[28] = 16

df$task[29] = "Dot to Dot"

df$task[98] = NA
df$number_done[98] = NA

df$number_done[100] = 6

df$task[101] = "Spot Difference"
df$number_done[101] = 5

df = df[-c(66, 103, 175, 237), ]

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
         
         "order" = {
           dict$description[i] = "order in which each task was selected"
           dict$type[i] = "integer"
           dict$value_range[i] = "any integer greater than 0"
         },
         
         "task" = {
           dict$description[i] = "name of task selected"
           dict$type[i] = "string"
           dict$value_range[i] = "Card Sorting, Birthdate Sorting, Dot to Dot, Word Search, or Spot Difference "
         },
         
         "number_done" = {
           dict$description[i] = "Card Sorting: number of cards sorted. Birthdate Sorting: number of dates moved. Dot to Dot: number of dot connected. Word Search: number of words found. Spot Difference: number of differences found."
           dict$type[i] = "integer"
           dict$value_range[i] = "any integer 0 or greater"
         },
         
         "number_correct" = {
           dict$description[i] = "Card Sorting: number of cards placed into correct suit pile. Birthdate Sorting, Word Search, Dot to Dot, and Spot Difference: NA."
           dict$type[i] = "integer"
           dict$value_range[i] = "any integer 0 or greater"
         }, 
         
         "score" = {
           dict$description[i] = "Card Sorting: reflects correctness of order within suits. Birthdate Sorting: number of dates in the correct relative positions. Word Search, Dot to Dot, and Spot Difference: NA."
           dict$type[i] = "integer"
           dict$value_range[i] = "any integer 0 or greater"
         },
         
         "stops" = {
           dict$description[i] = "number of stops sounded"
           dict$type[i] = "integer"
           dict$value_range[i] = "any integer 0 or greater"
         }
         
  )
}

#---- summary ----

names.summary = c(
  "user_id",
  "date",
  "total_duration",
  "switches", "tasks_attempted", "stops",
  "total_score", "total_bonus",
  "card_duration", "card_score", "card_bonus", "card_number_sorted", "card_number_sorted_correct",
  "birthdate_duration", "birthdate_score", "birthdate_bonus", "birthdate_items_moved",
  "dot_duration", "dot_score", "dot_bonus",
  "word_duration", "word_score", "word_bonus",
  "difference_duration", "difference_score", "difference_bonus"
)

participants = which(df$order == 1)
participants %<>% append(nrow(df)+1)

df.summary = data.frame(matrix(data = NA, nrow = 0, ncol = length(names.summary)))
names(df.summary) = names.summary
df.summary$date %<>% ymd_hms()

for (i in 1:(length(participants)-1)) {
  
  # pull participant's data from cleaned dataframe
  participant_data = df[participants[i]:(participants[i+1]-1), ]
  
  # set up a temporary empty dataframe for summary scores
  temp_df = data.frame(matrix(data = NA, nrow = 1, ncol = length(names.summary)))
  names(temp_df) = names.summary
  
  # fill in temporary dataframe
  temp_df$user_id = participant_data$user_id[1]
  temp_df$date = participant_data$date[1]
  temp_df$total_duration = sum(participant_data$duration, na.rm = TRUE)
  temp_df$switches = nrow(participant_data) - 1
  temp_df$tasks_attempted = unique(participant_data$task) %>% length()
  temp_df$stops = sum(participant_data$stops, na.rm = TRUE)
  
  ## card sort
  
  if (participant_data %>% 
      filter(task == "Card Sorting") %>% 
      nrow() == 0) {
    
    temp_df$card_duration = NA
    temp_df$card_score = NA
    temp_df$card_bonus = NA
    temp_df$card_number_sorted = NA
    temp_df$card_number_sorted_correct = NA
    
  } else {
    
    temp_df$card_duration = 
      participant_data %>% 
      filter(task == "Card Sorting") %>% 
      select(duration) %>% 
      sum()
    
    if (participant_data %>% 
        filter(task == "Card Sorting") %>% 
        select(score) %>% 
        drop_na() %>% 
        nrow() == 0) {
      
      temp_df$card_score = 0
      
    } else {
      
      temp_df$card_score = 
        participant_data %>% 
        filter(task == "Card Sorting") %>% 
        select(score) %>% 
        drop_na() %>% 
        tail(1) %>% 
        pull() %>% 
        as.numeric()
      
    }
    
    if (temp_df$card_score == 10) {
      temp_df$card_bonus = 5
    } else {temp_df$card_bonus = 0}
    
    temp_df$card_number_sorted = 
      participant_data %>% 
      filter(task == "Card Sorting") %>% 
      select(number_done) %>% 
      sum()
    
    temp_df$card_number_sorted_correct = 
      participant_data %>% 
      filter(task == "Card Sorting") %>% 
      select(number_correct) %>% 
      sum() 
    
  }
  
  ## birthdate sort
  
  if (participant_data %>% 
      filter(task == "Birthdate Sorting") %>% 
      nrow() == 0) {
    
    temp_df$birthdate_duration = NA
    temp_df$birthdate_score = NA
    temp_df$birthdate_bonus = NA
    temp_df$birthdate_items_moved = NA
    
  } else {
    
    temp_df$birthdate_duration = 
      participant_data %>% 
      filter(task == "Birthdate Sorting") %>% 
      select(duration) %>% 
      sum()
    
    temp_df$birthdate_score = 
      participant_data %>% 
      filter(task == "Birthdate Sorting") %>% 
      select(score) %>% 
      drop_na() %>% 
      tail(1) %>% 
      pull() %>% 
      as.numeric()
    
    if (temp_df$birthdate_score == 10) {
      temp_df$birthdate_bonus = 5
    } else {temp_df$birthdate_bonus = 0}
    
    temp_df$birthdate_items_moved = 
      participant_data %>% 
      filter(task == "Birthdate Sorting") %>% 
      select(number_done) %>% 
      sum()
    
  }
  
  ## dot to dot
  
  if (participant_data %>% 
      filter(task == "Dot to Dot") %>% 
      nrow() == 0) {
    
    temp_df$dot_duration = NA
    temp_df$dot_score = NA
    temp_df$dot_bonus = NA
    
  } else {
    
    temp_df$dot_duration = 
      participant_data %>% 
      filter(task == "Dot to Dot") %>% 
      select(duration) %>% 
      sum()
    
    temp_df$dot_score = 
      participant_data %>% 
      filter(task == "Dot to Dot") %>% 
      select(number_done) %>% 
      sum()
    
    if (temp_df$dot_score == 40) {
      temp_df$dot_bonus = 10
    } else (temp_df$dot_bonus = 0) 
    
  }
  
  ## word search
  
  if (participant_data %>% 
      filter(task == "Word Search") %>% 
      nrow() == 0) {
    
    temp_df$word_duration = NA
    temp_df$word_score = NA
    temp_df$word_bonus = NA
    
  } else {
    
    temp_df$word_duration = 
      participant_data %>% 
      filter(task == "Word Search") %>% 
      select(duration) %>% 
      sum()
    
    temp_df$word_score = 
      participant_data %>% 
      filter(task == "Word Search") %>% 
      select(number_done) %>% 
      sum()
    
    if (temp_df$word_score == 16) {
      temp_d$word_bonus = 5
    } else (temp_df$word_bonus = 0) 
    
  }
  
  ## spot difference
  
  if (participant_data %>% 
      filter(task == "Spot Difference") %>% 
      nrow() == 0) {
    
    temp_df$difference_duration = NA
    temp_df$difference_score = NA
    temp_df$difference_bonus = NA
    
  } else {
    
    temp_df$difference_duration = 
      participant_data %>% 
      filter(task == "Spot Difference") %>% 
      select(duration) %>% 
      sum()
    
    temp_df$difference_score = 
      participant_data %>% 
      filter(task == "Spot Difference") %>% 
      select(number_done) %>% 
      sum()
    
    if(temp_df$difference_score == 10) {
      temp_df$difference_bonus = 5
    } else (temp_df$difference_bonus = 0)
    
  }
  
  # total bonus
  if (temp_df$card_score > 0 & !is.na(temp_df$card_score) &
      temp_df$birthdate_score > 0 & !is.na(temp_df$birthdate_score) &
      temp_df$dot_score > 0 & !is.na(temp_df$dot_score) &
      temp_df$word_score > 0 & !is.na(temp_df$word_score) &
      temp_df$difference_score > 0 & !is.na(temp_df$difference_score)) { 
    
    temp_df$total_bonus = 10
    
  } else {temp_df$total_bonus = 0}
  
  # total score
  temp_df$total_score = 
    temp_df$total_bonus %>% 
    sum(temp_df$card_score, na.rm = TRUE) %>% 
    sum(temp_df$card_bonus, na.rm = TRUE) %>% 
    sum(temp_df$birthdate_score, na.rm = TRUE) %>% 
    sum(temp_df$birthdate_bonus, na.rm = TRUE) %>% 
    sum(temp_df$dot_score, na.rm = TRUE) %>% 
    sum(temp_df$dot_bonus, na.rm = TRUE) %>% 
    sum(temp_df$word_score, na.rm = TRUE) %>% 
    sum(temp_df$word_bonus, na.rm = TRUE) %>% 
    sum(temp_df$difference_score, na.rm = TRUE) %>% 
    sum(temp_df$difference_bonus, na.rm = TRUE)
  
  # append temp dataframe to full dataframe
  df.summary %<>% rbind(temp_df)
  
}

#---- data dictionary (summary) ----

# export column names
dict.summary = names(df.summary) %>%
  as.data.frame(stringsAsFactors = FALSE)
names(dict.summary) = "column_label"

# add columns to describe the variables in each column
dict.summary$description = NA
dict.summary$type = NA
dict.summary$value_range = NA

# fill in dictionary
for (i in 1:nrow(dict.summary)) {
  switch(dict.summary$column_label[i],
         
         "user_id" = {
           dict.summary$description[i] = "user ID"
           dict.summary$type[i] = "ID number"
           dict.summary$value_range[i] = "NA"
         },
         
         "date" = {
           dict.summary$description[i] = "date (yyyy-mm-dd)"
           dict.summary$type[i] = "date"
           dict.summary$value_range[i] = "NA"
         },
         
         "total_duration" = {
           dict.summary$description[i] = "total duration in seconds"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 to 240"
         },
         
         "switches" = {
           dict.summary$description[i] = "number of task switches made"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or greater"
         },
         
         "tasks_attempted" = {
           dict.summary$description[i] = "number of different tasks attempted"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "1 to 5"
         },
         
         "stops" = {
           dict.summary$description[i] = "total number of stops sounded"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or greater"
         },
         
         "total_score" = {
           dict.summary$description[i] = "sum of all task scores, task bonuses, and total bonus"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or greater"
         },
         
         "total_bonus" = {
           dict.summary$description[i] = "10 if score is at least 1 for each of the 5 tasks, otherwise 0"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or 10"
         },
         
         "card_duration" = {
           dict.summary$description[i] = "total time spent on Card Sorting (seconds)"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "1-240 if participant did Card Sorting, NA if not"
         },
         
         "card_score" = {
           dict.summary$description[i] = "Card Sorting score"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 to 10"
         },
         
         "card_bonus" = {
           dict.summary$description[i] = "Card Sorting bonus; 5 if Card Sorting score was perfect (10), otherwise 0"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or 5"
         },
         
         "card_number_sorted" = {
           dict.summary$description[i] = "total number of cards moved in Card Sorting"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or greater"
         }, 
         
         "card_number_sorted_correct" = {
           dict.summary$description[i] = "number of cards sorted into correct suit in Card Sorting"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or greater"
         },
         
         "birthdate_duration" = {
           dict.summary$description[i] = "total time spent on Birthdate Sorting (seconds)"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "1-240 if participant did Birthdate Sorting, NA if not"
         },
         
         "birthdate_score" = {
           dict.summary$description[i] = "Birthdate Sorting score"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 to 10"
         },
         
         "birthdate_bonus" = {
           dict.summary$description[i] = "Birthdate Sorting bonus; 5 if Birthdate Sorting score was perfect (10), otherwise 0"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or 5"
         },
         
         "birthdate_items_moved" = {
           dict.summary$description[i] = "total number of birthdates moved in Birthdate Sorting"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or greater"
         },
         
         "dot_duration" = {
           dict.summary$description[i] = "total time spent on Dot to Dot (seconds)"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "1-240 if participant did Dot to Dot, NA if not"
         },
         
         "dot_score" = {
           dict.summary$description[i] = "total number of dots connected in Dot to Dot"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 to 40"
         },
         
         "dot_bonus" = {
           dict.summary$description[i] = "Dot to Dot bonus; 10 if Dot to Dot score was perfect (40), otherwise 0"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or 10"
         },
         
         "word_duration" = {
           dict.summary$description[i] = "total time spent on Word Search (seconds)"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "1 to 240 if participant did Word Search, NA if not"
         },
         
         "word_score" = {
           dict.summary$description[i] = "total number of words found in Word Search"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 to 16"
         },
         
         "word_bonus" = {
           dict.summary$description[i] = "Word Search bonus; 5 if Word Search score was perfect (16), otherwise 0"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or 5"
         },
         
         "difference_duration" = {
           dict.summary$description[i] = "total time spend on Spot Difference (seconds)"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "1-240 if particpant did Spot Difference, NA if not"
         },
         
         "difference_score" = {
           dict.summary$description[i] = "total number of differences spotted in Spot Difference"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 to 10"
         },
         
         "difference_bonus" = {
           dict.summary$description[i] = "Spot Difference bonus; 5 if Spot Difference score was perfect (10), otherwise 0"
           dict.summary$type[i] = "integer"
           dict.summary$value_range[i] = "0 or 5"
         }
         
  )
}

#---- clean up ----

df_complex2 = df
dict_complex2 = dict

df_complex2_summary = df.summary
dict_complex2_summary = dict.summary

rm(list= ls()[!(ls() %in% df_to_keep)])
