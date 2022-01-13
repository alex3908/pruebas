# frozen_string_literal: true

namespace :set_custom_folder_users do
  desc "Run set pipeline task"

  task run: :environment do
    specialist_concept = FolderUserConcept.find_by_key(:customer_service_specialist)

    main_array = [
        [586,'andrea.morales@grupoorve.mx',specialist_concept],
        [1360,'pedro.perez@grupoorve.mx',specialist_concept],
        [1465,'andrea.morales@grupoorve.mx',specialist_concept],
        [1466,'andrea.morales@grupoorve.mx',specialist_concept],
        [1476,'andrea.morales@grupoorve.mx',specialist_concept],
        [2514,'andrea.morales@grupoorve.mx',specialist_concept],
        [4318,'andrea.morales@grupoorve.mx',specialist_concept],
        [4361,'andrea.morales@grupoorve.mx',specialist_concept],
        [4366,'andrea.morales@grupoorve.mx',specialist_concept],
        [4376,'andrea.morales@grupoorve.mx',specialist_concept],
        [4408,'andrea.morales@grupoorve.mx',specialist_concept],
        [4441,'andrea.morales@grupoorve.mx',specialist_concept],
        [4443,'andrea.morales@grupoorve.mx',specialist_concept],
        [4485,'andrea.morales@grupoorve.mx',specialist_concept],
        [4512,'andrea.morales@grupoorve.mx',specialist_concept],
        [4517,'andrea.morales@grupoorve.mx',specialist_concept],
        [4519,'andrea.morales@grupoorve.mx',specialist_concept],
        [4520,'andrea.morales@grupoorve.mx',specialist_concept],
        [4526,'andrea.morales@grupoorve.mx',specialist_concept],
        [4527,'andrea.morales@grupoorve.mx',specialist_concept],
        [4531,'andrea.morales@grupoorve.mx',specialist_concept],
        [4548,'andrea.morales@grupoorve.mx',specialist_concept],
        [4553,'andrea.morales@grupoorve.mx',specialist_concept],
        [4565,'andrea.morales@grupoorve.mx',specialist_concept],
        [4567,'andrea.morales@grupoorve.mx',specialist_concept],
        [4583,'andrea.morales@grupoorve.mx',specialist_concept],
        [4631,'andrea.morales@grupoorve.mx',specialist_concept],
        [4638,'andrea.morales@grupoorve.mx',specialist_concept],
        [4645,'andrea.morales@grupoorve.mx',specialist_concept],
        [4650,'andrea.morales@grupoorve.mx',specialist_concept],
        [4652,'andrea.morales@grupoorve.mx',specialist_concept],
        [4671,'andrea.morales@grupoorve.mx',specialist_concept],
        [4672,'andrea.morales@grupoorve.mx',specialist_concept],
        [4675,'andrea.morales@grupoorve.mx',specialist_concept],
        [4700,'andrea.morales@grupoorve.mx',specialist_concept],
        [4703,'andrea.morales@grupoorve.mx',specialist_concept],
        [4711,'andrea.morales@grupoorve.mx',specialist_concept],
        [4723,'andrea.morales@grupoorve.mx',specialist_concept],
        [4726,'andrea.morales@grupoorve.mx',specialist_concept],
        [4728,'andrea.morales@grupoorve.mx',specialist_concept],
        [4736,'andrea.morales@grupoorve.mx',specialist_concept],
        [4744,'andrea.morales@grupoorve.mx',specialist_concept],
        [4745,'andrea.morales@grupoorve.mx',specialist_concept],
        [4753,'andrea.morales@grupoorve.mx',specialist_concept],
        [4793,'andrea.morales@grupoorve.mx',specialist_concept],
        [4801,'andrea.morales@grupoorve.mx',specialist_concept],
        [4803,'andrea.morales@grupoorve.mx',specialist_concept],
        [4812,'andrea.morales@grupoorve.mx',specialist_concept],
        [4814,'andrea.morales@grupoorve.mx',specialist_concept],
        [4818,'andrea.morales@grupoorve.mx',specialist_concept],
        [4841,'andrea.morales@grupoorve.mx',specialist_concept],
        [4849,'andrea.morales@grupoorve.mx',specialist_concept],
        [4850,'andrea.morales@grupoorve.mx',specialist_concept],
        [4851,'andrea.morales@grupoorve.mx',specialist_concept],
        [4858,'andrea.morales@grupoorve.mx',specialist_concept],
        [4868,'andrea.morales@grupoorve.mx',specialist_concept],
        [4869,'andrea.morales@grupoorve.mx',specialist_concept],
        [4883,'andrea.morales@grupoorve.mx',specialist_concept],
        [4904,'andrea.morales@grupoorve.mx',specialist_concept],
        [4905,'andrea.morales@grupoorve.mx',specialist_concept],
        [4906,'andrea.morales@grupoorve.mx',specialist_concept],
        [4924,'andrea.morales@grupoorve.mx',specialist_concept],
        [4934,'andrea.morales@grupoorve.mx',specialist_concept],
        [4937,'andrea.morales@grupoorve.mx',specialist_concept],
        [4939,'andrea.morales@grupoorve.mx',specialist_concept],
        [4940,'andrea.morales@grupoorve.mx',specialist_concept],
        [4947,'andrea.morales@grupoorve.mx',specialist_concept],
        [4951,'andrea.morales@grupoorve.mx',specialist_concept],
        [4952,'andrea.morales@grupoorve.mx',specialist_concept],
        [4953,'andrea.morales@grupoorve.mx',specialist_concept],
        [4954,'andrea.morales@grupoorve.mx',specialist_concept],
        [4957,'andrea.morales@grupoorve.mx',specialist_concept],
        [4963,'andrea.morales@grupoorve.mx',specialist_concept],
        [4967,'andrea.morales@grupoorve.mx',specialist_concept],
        [4968,'andrea.morales@grupoorve.mx',specialist_concept],
        [4978,'andrea.morales@grupoorve.mx',specialist_concept],
        [4979,'andrea.morales@grupoorve.mx',specialist_concept],
        [4980,'andrea.morales@grupoorve.mx',specialist_concept],
        [4987,'andrea.morales@grupoorve.mx',specialist_concept],
        [5009,'andrea.morales@grupoorve.mx',specialist_concept],
        [5038,'andrea.morales@grupoorve.mx',specialist_concept],
        [5039,'andrea.morales@grupoorve.mx',specialist_concept],
        [5043,'andrea.morales@grupoorve.mx',specialist_concept],
        [5071,'andrea.morales@grupoorve.mx',specialist_concept],
        [5072,'andrea.morales@grupoorve.mx',specialist_concept],
        [5074,'andrea.morales@grupoorve.mx',specialist_concept],
        [5078,'andrea.morales@grupoorve.mx',specialist_concept],
        [5080,'andrea.morales@grupoorve.mx',specialist_concept],
        [5082,'andrea.morales@grupoorve.mx',specialist_concept],
        [5084,'andrea.morales@grupoorve.mx',specialist_concept],
        [5095,'andrea.morales@grupoorve.mx',specialist_concept],
        [5103,'andrea.morales@grupoorve.mx',specialist_concept],
        [5105,'andrea.morales@grupoorve.mx',specialist_concept],
        [5108,'andrea.morales@grupoorve.mx',specialist_concept],
        [5109,'andrea.morales@grupoorve.mx',specialist_concept],
        [5125,'andrea.morales@grupoorve.mx',specialist_concept],
        [5129,'andrea.morales@grupoorve.mx',specialist_concept],
        [5130,'andrea.morales@grupoorve.mx',specialist_concept],
        [5132,'andrea.morales@grupoorve.mx',specialist_concept],
        [5139,'andrea.morales@grupoorve.mx',specialist_concept],
        [5140,'andrea.morales@grupoorve.mx',specialist_concept],
        [5141,'andrea.morales@grupoorve.mx',specialist_concept],
        [5164,'andrea.morales@grupoorve.mx',specialist_concept],
        [5168,'andrea.morales@grupoorve.mx',specialist_concept],
        [5171,'andrea.morales@grupoorve.mx',specialist_concept],
        [5174,'andrea.morales@grupoorve.mx',specialist_concept],
        [5175,'andrea.morales@grupoorve.mx',specialist_concept],
        [5177,'andrea.morales@grupoorve.mx',specialist_concept],
        [5179,'andrea.morales@grupoorve.mx',specialist_concept],
        [5190,'andrea.morales@grupoorve.mx',specialist_concept],
        [5192,'andrea.morales@grupoorve.mx',specialist_concept],
        [5215,'andrea.morales@grupoorve.mx',specialist_concept],
        [5243,'andrea.morales@grupoorve.mx',specialist_concept],
        [5300,'andrea.morales@grupoorve.mx',specialist_concept],
        [5441,'jose.farfan@grupoorve.mx',specialist_concept],
        [5495,'jose.farfan@grupoorve.mx',specialist_concept],
        [5543,'jose.farfan@grupoorve.mx',specialist_concept],
        [5582,'jose.farfan@grupoorve.mx',specialist_concept],
        [5611,'jose.farfan@grupoorve.mx',specialist_concept],
        [5617,'jose.farfan@grupoorve.mx',specialist_concept],
        [5639,'jose.farfan@grupoorve.mx',specialist_concept],
        [5898,'jose.farfan@grupoorve.mx',specialist_concept],
        [5899,'jose.farfan@grupoorve.mx',specialist_concept],
        [5925,'jose.farfan@grupoorve.mx',specialist_concept],
        [5952,'jose.farfan@grupoorve.mx',specialist_concept],
        [5953,'jose.farfan@grupoorve.mx',specialist_concept],
        [6001,'jose.farfan@grupoorve.mx',specialist_concept],
        [6066,'jose.farfan@grupoorve.mx',specialist_concept],
        [6158,'jose.farfan@grupoorve.mx',specialist_concept],
        [6159,'jose.farfan@grupoorve.mx',specialist_concept],
        [6160,'jose.farfan@grupoorve.mx',specialist_concept],
        [6161,'jose.farfan@grupoorve.mx',specialist_concept],
        [6223,'jose.farfan@grupoorve.mx',specialist_concept],
        [6289,'jose.farfan@grupoorve.mx',specialist_concept],
        [6590,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6670,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6671,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6693,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6709,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6714,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6772,'jose.farfan@grupoorve.mx',specialist_concept],
        [6773,'jose.farfan@grupoorve.mx',specialist_concept],
        [6784,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6785,'jose.farfan@grupoorve.mx',specialist_concept],
        [6801,'ana.suarez@grupoorve.mx',specialist_concept],
        [6873,'ana.suarez@grupoorve.mx',specialist_concept],
        [6883,'ana.suarez@grupoorve.mx',specialist_concept],
        [6892,'ana.suarez@grupoorve.mx',specialist_concept],
        [6897,'ana.suarez@grupoorve.mx',specialist_concept],
        [6919,'ana.suarez@grupoorve.mx',specialist_concept],
        [6933,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6934,'alexia.montoya@grupoorve.mx',specialist_concept],
        [6976,'ana.suarez@grupoorve.mx',specialist_concept],
        [6982,'ana.suarez@grupoorve.mx',specialist_concept],
        [7007,'ana.suarez@grupoorve.mx',specialist_concept],
        [7008,'ana.suarez@grupoorve.mx',specialist_concept],
        [7298,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7301,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7306,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7307,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7308,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7309,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7312,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7320,'ana.suarez@grupoorve.mx',specialist_concept],
        [7322,'ana.suarez@grupoorve.mx',specialist_concept],
        [7331,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7333,'ana.suarez@grupoorve.mx',specialist_concept],
        [7335,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7339,'ana.suarez@grupoorve.mx',specialist_concept],
        [7340,'ana.suarez@grupoorve.mx',specialist_concept],
        [7341,'ana.suarez@grupoorve.mx',specialist_concept],
        [7343,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7344,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7349,'ana.suarez@grupoorve.mx',specialist_concept],
        [7356,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7357,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7359,'ana.suarez@grupoorve.mx',specialist_concept],
        [7364,'ana.suarez@grupoorve.mx',specialist_concept],
        [7366,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7368,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7371,'ana.suarez@grupoorve.mx',specialist_concept],
        [7374,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7381,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7384,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7385,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7386,'ana.suarez@grupoorve.mx',specialist_concept],
        [7387,'ana.suarez@grupoorve.mx',specialist_concept],
        [7388,'ana.suarez@grupoorve.mx',specialist_concept],
        [7389,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7395,'ana.suarez@grupoorve.mx',specialist_concept],
        [7396,'ana.suarez@grupoorve.mx',specialist_concept],
        [7397,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7398,'ana.suarez@grupoorve.mx',specialist_concept],
        [7399,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7400,'ana.suarez@grupoorve.mx',specialist_concept],
        [7408,'ana.suarez@grupoorve.mx',specialist_concept],
        [7409,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7410,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7411,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7412,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7416,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7417,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7418,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7419,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7426,'ana.suarez@grupoorve.mx',specialist_concept],
        [7434,'andrea.morales@grupoorve.mx',specialist_concept],
        [7435,'andrea.morales@grupoorve.mx',specialist_concept],
        [7436,'andrea.morales@grupoorve.mx',specialist_concept],
        [7437,'andrea.morales@grupoorve.mx',specialist_concept],
        [7445,'ana.suarez@grupoorve.mx',specialist_concept],
        [7446,'ana.suarez@grupoorve.mx',specialist_concept],
        [7468,'ana.suarez@grupoorve.mx',specialist_concept],
        [7469,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7470,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7478,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7479,'ana.suarez@grupoorve.mx',specialist_concept],
        [7490,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7505,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7506,'ana.suarez@grupoorve.mx',specialist_concept],
        [7507,'ana.suarez@grupoorve.mx',specialist_concept],
        [7509,'ana.suarez@grupoorve.mx',specialist_concept],
        [7510,'ana.suarez@grupoorve.mx',specialist_concept],
        [7512,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7515,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7517,'ana.suarez@grupoorve.mx',specialist_concept],
        [7519,'ana.suarez@grupoorve.mx',specialist_concept],
        [7520,'ana.suarez@grupoorve.mx',specialist_concept],
        [7522,'ana.suarez@grupoorve.mx',specialist_concept],
        [7525,'jose.farfan@grupoorve.mx',specialist_concept],
        [7527,'ana.suarez@grupoorve.mx',specialist_concept],
        [7528,'ana.suarez@grupoorve.mx',specialist_concept],
        [7535,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7541,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7542,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7543,'ana.suarez@grupoorve.mx',specialist_concept],
        [7544,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7546,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7547,'ana.suarez@grupoorve.mx',specialist_concept],
        [7549,'ana.suarez@grupoorve.mx',specialist_concept],
        [7551,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7556,'ana.suarez@grupoorve.mx',specialist_concept],
        [7561,'ana.suarez@grupoorve.mx',specialist_concept],
        [7562,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7563,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7573,'ana.suarez@grupoorve.mx',specialist_concept],
        [7574,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7575,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7576,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7584,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7586,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7587,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7589,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7592,'ana.suarez@grupoorve.mx',specialist_concept],
        [7593,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7594,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7599,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7606,'ana.suarez@grupoorve.mx',specialist_concept],
        [7607,'ana.suarez@grupoorve.mx',specialist_concept],
        [7608,'ana.suarez@grupoorve.mx',specialist_concept],
        [7609,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7611,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7612,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7613,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7614,'ana.suarez@grupoorve.mx',specialist_concept],
        [7615,'ana.suarez@grupoorve.mx',specialist_concept],
        [7618,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7622,'ana.suarez@grupoorve.mx',specialist_concept],
        [7623,'ana.suarez@grupoorve.mx',specialist_concept],
        [7631,'ana.suarez@grupoorve.mx',specialist_concept],
        [7633,'ana.suarez@grupoorve.mx',specialist_concept],
        [7641,'ana.suarez@grupoorve.mx',specialist_concept],
        [7642,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7643,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7646,'ana.suarez@grupoorve.mx',specialist_concept],
        [7647,'ana.suarez@grupoorve.mx',specialist_concept],
        [7651,'ana.suarez@grupoorve.mx',specialist_concept],
        [7658,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7664,'ana.suarez@grupoorve.mx',specialist_concept],
        [7684,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7686,'ana.suarez@grupoorve.mx',specialist_concept],
        [7689,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7690,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7694,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7695,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7697,'ana.suarez@grupoorve.mx',specialist_concept],
        [7705,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7707,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7710,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7711,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7712,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7714,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7718,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7722,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7723,'ana.suarez@grupoorve.mx',specialist_concept],
        [7727,'ana.suarez@grupoorve.mx',specialist_concept],
        [7728,'ana.suarez@grupoorve.mx',specialist_concept],
        [7729,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7730,'ana.suarez@grupoorve.mx',specialist_concept],
        [7737,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7738,'ana.suarez@grupoorve.mx',specialist_concept],
        [7745,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7746,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7747,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7756,'ana.suarez@grupoorve.mx',specialist_concept],
        [7764,'ana.suarez@grupoorve.mx',specialist_concept],
        [7768,'ana.suarez@grupoorve.mx',specialist_concept],
        [7771,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7777,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7780,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7781,'ana.suarez@grupoorve.mx',specialist_concept],
        [7782,'ana.suarez@grupoorve.mx',specialist_concept],
        [7783,'ana.suarez@grupoorve.mx',specialist_concept],
        [7785,'ana.suarez@grupoorve.mx',specialist_concept],
        [7787,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7790,'ana.suarez@grupoorve.mx',specialist_concept],
        [7792,'ana.suarez@grupoorve.mx',specialist_concept],
        [7794,'ana.suarez@grupoorve.mx',specialist_concept],
        [7799,'ana.suarez@grupoorve.mx',specialist_concept],
        [7800,'ana.suarez@grupoorve.mx',specialist_concept],
        [7801,'ana.suarez@grupoorve.mx',specialist_concept],
        [7802,'ana.suarez@grupoorve.mx',specialist_concept],
        [7803,'ana.suarez@grupoorve.mx',specialist_concept],
        [7804,'ana.suarez@grupoorve.mx',specialist_concept],
        [7805,'ana.suarez@grupoorve.mx',specialist_concept],
        [7806,'ana.suarez@grupoorve.mx',specialist_concept],
        [7807,'ana.suarez@grupoorve.mx',specialist_concept],
        [7808,'ana.suarez@grupoorve.mx',specialist_concept],
        [7809,'ana.suarez@grupoorve.mx',specialist_concept],
        [7810,'ana.suarez@grupoorve.mx',specialist_concept],
        [7812,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7813,'ana.suarez@grupoorve.mx',specialist_concept],
        [7816,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7821,'ana.suarez@grupoorve.mx',specialist_concept],
        [7823,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7826,'ana.suarez@grupoorve.mx',specialist_concept],
        [7833,'ana.suarez@grupoorve.mx',specialist_concept],
        [7834,'ana.suarez@grupoorve.mx',specialist_concept],
        [7835,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7837,'ana.suarez@grupoorve.mx',specialist_concept],
        [7842,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7843,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7844,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7845,'ana.suarez@grupoorve.mx',specialist_concept],
        [7846,'ana.suarez@grupoorve.mx',specialist_concept],
        [7847,'ana.suarez@grupoorve.mx',specialist_concept],
        [7854,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7855,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7857,'ana.suarez@grupoorve.mx',specialist_concept],
        [7859,'jose.farfan@grupoorve.mx',specialist_concept],
        [7860,'ana.suarez@grupoorve.mx',specialist_concept],
        [7863,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7866,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7868,'ana.suarez@grupoorve.mx',specialist_concept],
        [7869,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7870,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7873,'ana.suarez@grupoorve.mx',specialist_concept],
        [7876,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7877,'ana.suarez@grupoorve.mx',specialist_concept],
        [7879,'ana.suarez@grupoorve.mx',specialist_concept],
        [7882,'ana.suarez@grupoorve.mx',specialist_concept],
        [7883,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7884,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7885,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7890,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7896,'ana.suarez@grupoorve.mx',specialist_concept],
        [7897,'ana.suarez@grupoorve.mx',specialist_concept],
        [7898,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7902,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7903,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7904,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7906,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7910,'ana.suarez@grupoorve.mx',specialist_concept],
        [7911,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7916,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7917,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7922,'ana.suarez@grupoorve.mx',specialist_concept],
        [7923,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7930,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7933,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7936,'ana.suarez@grupoorve.mx',specialist_concept],
        [7942,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7943,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7944,'alexia.montoya@grupoorve.mx',specialist_concept],
        [7945,'ana.suarez@grupoorve.mx',specialist_concept],
        [8112,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8115,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8121,'ana.suarez@grupoorve.mx',specialist_concept],
        [8123,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8124,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8131,'ana.suarez@grupoorve.mx',specialist_concept],
        [8132,'ana.suarez@grupoorve.mx',specialist_concept],
        [8133,'ana.suarez@grupoorve.mx',specialist_concept],
        [8134,'jose.farfan@grupoorve.mx',specialist_concept],
        [8136,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8142,'ana.suarez@grupoorve.mx',specialist_concept],
        [8147,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8151,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8152,'ana.suarez@grupoorve.mx',specialist_concept],
        [8153,'ana.suarez@grupoorve.mx',specialist_concept],
        [8154,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8155,'ana.suarez@grupoorve.mx',specialist_concept],
        [8386,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8387,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8393,'ana.suarez@grupoorve.mx',specialist_concept],
        [8588,'ana.suarez@grupoorve.mx',specialist_concept],
        [8629,'alexia.montoya@grupoorve.mx',specialist_concept],
        [8636,'ana.suarez@grupoorve.mx',specialist_concept]
    ]

    main_array.each do |emails|
      folder_folio = emails.first
      user_email = emails.second.try(:strip).try(:downcase)
      concept = emails.third

      user = User.find_by(email: user_email)
      folder = Folder.find(folder_folio)

      puts "No se encontro el usuario #{user_email}" if user.nil?
      puts "No se encontro el expediente #{folder_folio}" if folder.nil?

      if folder.present? && user.present?
        specialist_in_folder = folder.folder_users.where(folder_user_concept: concept)
        unless specialist_in_folder.present?
          FolderUser.create!(user: user, role: user.role, folder: folder, percentage: 0, visible: true, folder_user_concept: concept)
        end
      end
    end
  end
end