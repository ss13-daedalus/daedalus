datum/news_topic_handler
	Topic(href,href_list)
		var/client/C = locate(href_list["client"])
		if(href_list["action"] == "show_all_news")
			C.display_all_news_list()
		else if(href_list["action"] == "remove")
			C.remove_news(text2num(href_list["ID"]))
		else if(href_list["action"] == "edit")
			C.edit_news(text2num(href_list["ID"]))
		else if(href_list["action"] == "show_news")
			C.display_news_list()
		else if(href_list["action"] == "add_news")
			C.add_news()