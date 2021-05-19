/*
 * Copyright (c) 2021 Google LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */

package com.google.api.services.samples.adsense.cmdline;

import com.google.api.services.adsense.v2.Adsense;
import com.google.api.services.adsense.v2.model.ListUrlChannelsResponse;
import com.google.api.services.adsense.v2.model.UrlChannel;
import java.util.List;

/**
*
* This example gets all URL channels in an ad client.
*
* Tags: accounts.adclients.urlchannels.list
*
*/
public class GetAllUrlChannels {

  /**
   * Runs this sample.
   *
   * @param adsense AdSense service object on which to run the requests.
   * @param adClientId the ID for the ad client to be used.
   * @param maxPageSize the maximum page size to retrieve.
   * @throws Exception
   */
  public static void run(Adsense adsense, String adClientId, int maxPageSize) throws Exception {
    System.out.println("=================================================================");
    System.out.printf("Listing all URL channels for ad client %s\n", adClientId);
    System.out.println("=================================================================");

    // Retrieve URL channel list in pages and display the data as we receive it.
    String pageToken = null;
    do {
      ListUrlChannelsResponse response = adsense.accounts().adclients().urlchannels()
          .list(adClientId)
          .setPageSize(maxPageSize)
          .setPageToken(pageToken)
          .execute();
      List<UrlChannel> urlChannels = response.getUrlChannels();

      if (urlChannels != null && !urlChannels.isEmpty()) {
        for (UrlChannel channel : urlChannels) {
          System.out.printf("URL channel with URI pattern \"%s\" was found.\n",
              channel.getUriPattern());
        }
      } else {
        System.out.println("No URL channels found.");
      }

      pageToken = response.getNextPageToken();
    } while (pageToken != null);

    System.out.println();
  }
}
