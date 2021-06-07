#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Bookkeeping Task 1") %>% 
  as.data.frame()

# answer key

## task 1
task1_correct = c(
  "Receipt: Amount $70, billing: 02-Jul, payment: 09-Jul, filing: 26-Jul",
  "Receipt: Amount $10, billing: 01-Aug, payment: 09-Aug, filing: 30-Sep"
)

task1_incorrect = 
  "Receipt: Amount $45, billing: 13-Aug, payment: 09-Oct, filing: 31-Oct"

## task 2
task2_correct = c(
  "Receipt: Amount $90, billing: 13-Jul, payment: 25-Jul, filing: 04-Aug",
  "Receipt: Amount $60, billing: 03-Sep, payment: 10-Oct, filing: 24-Oct"
)

task2_incorrect = c(
  "Receipt: Amount $150, billing: 01-Jun, payment: 28-Jun, filing: 12-Aug",
  "Receipt: Amount $95, billing: 15-Nov, payment: 22-Nov, filing: 11-Dec",
  "Receipt: Amount $100, billing: 30-Jun, payment: 05-Jul, filing: 01-Sep"
)

## task 3
task3_correct = 
  "Receipt: Amount $75, billing: 13-Aug, payment: 09-Sep, filing: 11-Sep"
  
task3_incorrect = c(
  "Receipt: Amount $80, billing: 20-Jun, payment: 13-Aug, filing: 03-Oct",
  "Receipt: Amount $80, billing: 14-Oct, payment: 18-Nov, filing: 10-Dec",
  "Receipt: Amount $60, billing: 05-Jun, payment: 11-Jul, filing: 26-Jul"
)

# set column names
names = c("user_id",
          "date",
          "order",
          "task",
          "switch_duration",
          "duration",
          "submitted",
          "method",
          "correct",
          "incorrect",
          "incorrect_date",
          "incorrect_account",
          "incorrect_duplicate"
          )

# find each task starts
started = which(df_raw$tag2 == "Started")

# number of starts
n = length(started)

# add 1 to end of start for subsetting last task start
started %<>% append(nrow(df_raw))

# set up empty dataframe
df = data.frame(matrix(data = NA, nrow = 0, ncol = length(names)))
names(df) = names
df$date %<>% ymd_hms()

#---- pull data ----

# for each task start...
for (i in 1:n) {
  
  # subset participant's rows
  range = (started[i]):(started[i+1]-1)
  raw_user_data = df_raw[range, ]
  
  # find task switches
  switches = 
    which(grepl("Selecting Task", raw_user_data$tag2)) %>%
    append(which(grepl("Revision Started", raw_user_data$tag2))) %>% 
    sort()
  
  if (identical(switches, integer(0))) { # if there are only Game Ended rows
    next 
  }
  
  if (grepl("Game Ended", raw_user_data$tag2[nrow(raw_user_data)])) {
    switches %<>% 
      append(head(which(raw_user_data$tag2 == "Game Ended"), 1))
  } else {
    switches %<>%
      append(nrow(raw_user_data) + 1)
  }
  
  # pull user ID
  temp_id = raw_user_data$user_id[1]
  
  # set up participant dataframe
  temp_df = matrix(data = NA, 
                   nrow = length(switches) - 1, 
                   ncol = length(names)) %>%
    data.frame()
  
  names(temp_df) = names
  
  temp_df$user_id = raw_user_data$user_id[1]
  
  temp_df$date %<>% ymd_hms()
  
  temp_df$order = seq(1, (length(switches) - 1))
  
  temp_df$correct = 0
  temp_df$incorrect = 0
  temp_df$incorrect_date = 0
  temp_df$incorrect_account = 0
  temp_df$incorrect_duplicate = 0
 
  # fill in task data
  for (s in 1:(length(switches) - 1)) {
    
    # subset task rows
    task_range = switches[s]:(switches[s+1]-1)
    raw_task_data = raw_user_data[task_range, ]
    
    # date
    temp_date = raw_task_data$created_at[1]
    temp_df$date[s] = temp_date
    
    # task
    temp_task = raw_task_data$tag2[1]
    
    if (grepl("Selecting Task", temp_task)) {
      
      temp_task %<>% strsplit(" ")
      temp_task = temp_task[[1]][3] 
        
    } 
    
    if (grepl("Revision Started", temp_task)) {
      
      temp_task %<>% strsplit(" ")
      temp_task = temp_task[[1]][2]
      
    }
    
    temp_df$task[s] = temp_task

    # switch duration
    temp_switch = raw_user_data$created_at[(switches[s]-1)] %>% 
      interval(raw_task_data$created_at[1]) %>% 
      time_length("seconds")
    
    temp_df$switch_duration[s] = temp_switch
    
    # duration
    temp_duration = raw_task_data$created_at[1] %>% 
      interval(raw_task_data$created_at[nrow(raw_task_data)]) %>% 
      time_length("seconds")
    
    temp_df$duration[s] = temp_duration
    
    # submitted
    if (!grepl("Submitted", raw_task_data$tag2) %>% any()) {
      temp_df$submitted[s] = "no"
    } else {
      if (raw_task_data$tag3[which(grepl("Submitted", raw_task_data$tag2))] ==
          "Correct: true") {
        temp_df$submitted[s] = "correct"
      }
      if (raw_task_data$tag3[which(grepl("Submitted", raw_task_data$tag2))] ==
          "Correct: false") {
        temp_df$submitted[s] = "incorrect"
      }
    } 
      
    # receipt scoring
    temp_receipt_df = raw_task_data %>% 
      filter(grepl("Receipt", tag2)) %>% 
      select(tag2) %>% 
      filter(!grepl("Submitted", tag2))
    
    if (nrow(temp_receipt_df > 0)) {
      
      temp_receipt_list = vector(mode = "character")
      
      for (r in 1:nrow(temp_receipt_df)) {
        
        ## split up receipt info
        
        temp_receipt = temp_receipt_df$tag2[r] %>%
          str_split(", duplicate: ")
        
        temp_receipt_df$receipt[r] = temp_receipt[[1]][1]
        
        temp_receipt = temp_receipt[[1]][2] %>%
          strsplit(", ")
        
        temp_receipt_df$duplicate[r] = temp_receipt[[1]][1]
        
        temp_receipt = temp_receipt[[1]][2] %>%
          strsplit(" ")
        
        temp_receipt_df$account[r] = temp_receipt[[1]][3]
        
        temp_receipt_df$select[r] = temp_receipt[[1]][4]
        
        ## pull receipts into list
        
        if (temp_receipt_df$select[r] == "Selected") {
          
          temp_receipt = temp_receipt_df$receipt[r]
          
          if (temp_receipt_df$duplicate[r] == "true") {
            temp_receipt %<>% paste0(", duplicate")
          }
          
          temp_receipt_list %<>% append(temp_receipt)
          
        }
        
        if (temp_receipt_df$select[r] == "Deselected") {
          
          temp_deselect = which(temp_receipt_list == temp_receipt_df$receipt[r]) %>% 
            head(1)
          
          temp_receipt_list = temp_receipt_list[-temp_deselect]
          
        }
        
      }
      
      if (length(temp_receipt_list > 0)) {
        
        ## task 1
        
        if (temp_task == "1") {
          
          # method
          temp_method = raw_task_data %>% 
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>% 
            select(tag2)
          
          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "correct"
          } 
          
          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "incorrect"
          }
          
          # receipts
          for (c in 1:length(temp_receipt_list)) {
            
            temp_receipt = temp_receipt_list[c]
            
            # correct
            if (temp_receipt %in% task1_correct) {
              temp_df$correct[s] = temp_df$correct[s] + 1
            } else {
              # incorrect 
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1
              
              # incorrect date
              if (grepl("Jul", temp_receipt) |
                  grepl("Aug", temp_receipt)) {
                temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
              }
              
              # incorrect account
              if (! temp_receipt %in% task1_correct &
                  ! temp_receipt %in% task1_incorrect) {
                temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
              }
              
              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }
              
            }
            
          }
          
        }
        
        ## task 2
        
        if (temp_task == "2") {
          
          # method
          temp_method = raw_task_data %>% 
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>% 
            select(tag2)
          
          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "incorrect"
          } 
          
          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "correct"
          }
          
          # receipts
          for (c in 1:length(temp_receipt_list)) {
            
            temp_receipt = temp_receipt_list[c]
            
            # correct
            if (temp_receipt %in% task2_correct) {
              temp_df$correct[s] = temp_df$correct[s] + 1
            } else {
              # incorrect 
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1
              
              # incorrect date
              if (grepl("Jul", temp_receipt) |
                  grepl("Sep", temp_receipt)) {
                temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
              }
              
              # incorrect account
              if (! temp_receipt %in% task2_correct &
                  ! temp_receipt %in% task2_incorrect) {
                temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
              }
              
              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }
              
            }
            
          }
          
        }
        
        ## task 3
        
        if (temp_task == "3") {
          
          # method
          temp_method = raw_task_data %>% 
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>% 
            select(tag2)
          
          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "incorrect"
          } 
          
          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "correct"
          }
          
          # receipts
          for (c in 1:length(temp_receipt_list)) {
            
            temp_receipt = temp_receipt_list[c]
            
            # correct
            if (temp_receipt %in% task3_correct) {
              temp_df$correct[s] = temp_df$correct[s] + 1
            } else {
              # incorrect 
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1
              
              # incorrect date
              if (grepl("Aug", temp_receipt) |
                  grepl("Sep", temp_receipt) |
                  grepl("Oct", temp_receipt)) {
                temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
              }
              
              # incorrect account
              if (! temp_receipt %in% task3_correct &
                  ! temp_receipt %in% task3_incorrect) {
                temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
              }
              
              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }
              
            }
            
          }
          
        }
        
      }
      
    }
    
  }
  
  # append participant dataframe to overall dataframe
  df %<>% rbind(temp_df)
  
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
for (d in 1:nrow(dict)) {
  
  switch(dict$column_label[d],
         
         "user_id" = {
           dict$description[d] = "user ID"
           dict$type[d] = "ID number"
           dict$value_range[d] = "NA"
         },
         
         "date" = {
           dict$description[d] = "date (yyyy-mm-dd hh-mm-ss UTC)"
           dict$type[d] = "date"
           dict$value_range[d] = "NA"
         },
         
         "order" = {
           dict$description[d] = "order in which each task was selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "any integer greater than 0"
         },
         
         "task" = {
           dict$description[d] = "number of task selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "1 to 3"
         },
         
         "switch_duration" = {
           dict$description[d] = "duration between end of last task and start if present task (or in the case of the first task, the beginning of the Bookkeeping Task and the start of the first task within that) in seconds"
           dict$type[d] = "integer"
           dict$value_range[d] = "greater than 0"
         },
         
         "duration" = {
           dict$description[d] = "task duration in seconds"
           dict$type[d] = "integer"
           dict$value_range[d] = "greater than 0"
         },
         
         "submitted" = {
           dict$description[d] = "whether task was submitted or not"
           dict$type[d] = "factor"
           dict$value_range[d] = "no (not submitted), correct (submitted and correct), or incorrect (submitted and incorrect)"
         },
         
         "method" = {
           dict$description[d] = "whether method selected to tally receipts (average or sum) was correcft or not"
           dict$type[d] = "factor"
           dict$value_range[d] = "correct or incorrect"
         },
         
         "correct" = {
           dict$description[d] = "number of correct receipts selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         },
         
         "incorrect" = {
           dict$description[d] = "total number of incorrect receipts selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         },
         
         "incorrect_date" = {
           dict$description[d] = "number of incorrect receipts selected that had some date overlap with correct receipts"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         },
         
         "incorrect_account" = {
           dict$description[d] = "number of receipts selected from incorrect account"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         },
         
         "incorrect_duplicate" = {
           dict$description[d] = "number of duplicate receipts selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         }
         
         )
}

#---- clean up ----

df_book1 = df
dict_book1 = dict

rm(list = ls()[!(ls() %in% df_to_keep)])