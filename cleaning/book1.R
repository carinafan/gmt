#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Bookkeeping Task 1") %>% 
  as.data.frame()

# answer key
task3_receipts = c(
  "Receipt: Amount $80, billing: 20-Jun, payment: 13-Aug, filing: 03-Oct",
  "Receipt: Amount $80, billing: 14-Oct, payment: 18-Nov, filing: 10-Dec",
  "Receipt: Amount $60, billing: 05-Jun, payment: 11-Jul, filing: 26-Jul",
  "Receipt: Amount $75, billing: 13-Aug, payment: 09-Sep, filing: 11-Sep"
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
          "incorrect_type",
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
  temp_df$incorrect_type = 0
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
    }
    
   
    
    # ## task 1
    # 
    # if (temp_task == "1") {
    #   
    # }
    #   
    # ## task 2
    # 
    # if (temp_task == "2") {
    #     
    #     
    # }
      
    ## task 3
      
    # if (temp_task == "3") {
    #   
    #   if (nrow(temp_receipts) > 0) {
    #     
    #     # method
    #     if (any(grepl("Average Selected", raw_task_data$tag2))) {
    #       temp_df$method[s] = "incorrect"
    #     } 
    #     
    #     if (any(grepl("Sum Selected", raw_task_data$tag2))) {
    #       temp_df$method[s] = "correct"
    #     }
    #     
    #     for (r in 1:nrow(temp_receipts)) {
    #       
    #       temp_receipt = temp_receipts$tag2[r] %>% 
    #         strsplit(", duplicate")
    #       
    #       ### correct 
    #       if (temp_receipt[[1]][1] %in% task3_receipts &
    #           grepl("false", temp_receipt[[1]][2])) {
    #         
    #         temp_df$correct[s] = temp_df$correct[s] + 1
    #         
    #       }  else {
    #         
    #         ### incorrect
    #         temp_df$incorrect[s] = temp_df$incorrect[s] + 1
    #         
    #         ### incorrect account
    #         temp_account = temp_receipt[[1]][2] %>% 
    #           strsplit("Account ")
    #         temp_account = temp_account[[1]][2] %>% 
    #           strsplit(" Selected")
    #         temp_account = temp_account[[1]][1]
    #         
    #         if (temp_account != "1937") {
    #           temp_df$incorrect_accountp[s] = temp_df$incorrect_account[s] + 1
    #         }
    #         
    #       }
    #       
    #     }
    #   }
    # 
    # }
    
    
    
    
    
    
    
    
  }
  
  # append participant dataframe to overall dataframe
  df %<>% rbind(temp_df)
  
}

#---- data dictionary ----