class DefectList < ActiveRecord::Base

  BUG = "Bug"

  def self.create_defect_information(projects)
    data = []
    projects.each do |project|
      project_info = {}
      project_info[:name] = project.name
      project_info[:defects] = []
      project_info[:defects_count] = 0
      project_info[:graph_data] = {}
      project_info[:graph_data][:days] = {}
      project_info[:priority_data] = {}
      project_info[:priority_graph_data] = {}

      project.issues.each do |issue|
        if issue.fields['issuetype']['name'] == BUG
          project_info[:defects_count] +=1

          date = Date.parse(issue.fields['created'])
          priority = issue.fields['priority']['name']

          project_info[:graph_data][:days][date] = 0 unless project_info[:graph_data][:days][date]
          project_info[:graph_data][:days][date] += 1

          project_info[:priority_data][priority] = 0 unless project_info[:priority_data][priority]
          project_info[:priority_data][priority] += 1

          if !project_info[:priority_graph_data][priority]
            project_info[:priority_graph_data][priority] = {}
            project_info[:priority_graph_data][priority][:days] = {}
          end

          project_info[:priority_graph_data][priority][:days][date] = 0 unless
            project_info[:priority_graph_data][priority][:days][date]
          project_info[:priority_graph_data][priority][:days][date] += 1

          project_info[:defects].push({
            summary: issue.summary,
            priority: issue.fields['priority']['name'],
            timespent: issue.fields['timespent'],
            assignee: (issue.fields['assignee'] || {})['emailAddress'],
            estimate: issue.fields['timeoriginalestimate'],
            date: date
          })
        end
      end

      project_info[:graph_data][:days] =
        self.populate_days_with_no_data(project_info[:graph_data][:days].sort.to_h)

      project_info[:priority_data] =
        self.transform_hash_to_array_of_hashes(project_info[:priority_data], :defect_count)

      data.push(project_info)
    end
    return self.aggregate_week_and_month_data(data)
  end

  def self.populate_days_with_no_data(existing_days)
    return {} unless existing_days.first
    existing_days = self.force_week_to_start_on_monday(existing_days)
    current = existing_days.keys.first
    finish = existing_days.keys.last
    until current == finish
      existing_days[current] = 0 unless existing_days[current]
      current = current + 1
    end
    return existing_days.sort.to_h
  end

  def self.aggregate_week_and_month_data(data)
    data.each do |project_info|

      storage = []
      project_info[:graph_data][:weeks] = {}
      project_info[:graph_data][:months] = {}

      project_info[:graph_data][:weeks] =
        self.aggregate_week_data(project_info[:graph_data][:days])
      project_info[:graph_data][:months] =
        self.aggregate_month_data(project_info[:graph_data][:weeks])

      project_info[:priority_graph_data].each do |key, values|

        project_info[:priority_graph_data][key][:days] =
          self.populate_days_with_no_data(project_info[:priority_graph_data][key][:days].sort.to_h)

        values[:days].each do |day, count|

          project_info[:priority_graph_data][key][:weeks] =
            self.aggregate_week_data(project_info[:priority_graph_data][key][:days])
          project_info[:priority_graph_data][key][:months] =
            self.aggregate_month_data(project_info[:priority_graph_data][key][:weeks])
        end
        storage = []
        storage.push(self.transform_hash_to_array_of_hashes(project_info[:priority_graph_data], :graph_data))
      end
      project_info[:priority_graph_data] = storage.flatten
    end
    return {projects: data}
  end

  def self.transform_hash_to_array_of_hashes(to_transform, key)
    storage = []
    to_transform.to_a.each do |data|
      storage.push({
        name: data[0],
        "#{key}": data[1]
        })
    end
    return storage
  end

  def self.force_week_to_start_on_monday(existing_days)
    current = existing_days.keys.first
    until current.monday?
      current = current -1
      existing_days[current] = 0
    end
    return existing_days.sort.to_h
  end

  def self.aggregate_week_data(days)
    current_week =  nil
    weeks = {}
    days.each do |week, count|
      if !current_week
        current_week = week
        weeks[current_week] = count
      elsif week <= current_week + 6
        weeks[current_week] += count
      else
        current_week = week
        weeks[current_week] = count
      end
    end
    return weeks
  end

  def self.aggregate_month_data(weeks)
    return unless weeks
    current_month = nil
    months = {}
    weeks.each do |date, count|
      if !current_month
        current_month = date.month
        months[current_month] = count
      elsif current_month == date.month
        months[current_month] += count
      else
        current_month = date.month
        months[current_month] = count
      end
    end
    return months
  end
end
