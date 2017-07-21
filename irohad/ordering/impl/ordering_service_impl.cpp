/**
 * Copyright Soramitsu Co., Ltd. 2017 All Rights Reserved.
 * http://soramitsu.co.jp
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "ordering/impl/ordering_service_impl.hpp"

namespace iroha {
  namespace ordering {
    OrderingServiceImpl::OrderingServiceImpl(size_t max_size,
                                             size_t delay_seconds)
        : max_size_(max_size), delay_seconds_(delay_seconds) {}

    void OrderingServiceImpl::propagate_transaction(
        const model::Transaction &transaction) {
      queue_.push(transaction);
    }

    rxcpp::observable<model::Proposal> OrderingServiceImpl::on_proposal() {
      return proposals_.get_observable();
    }

    void OrderingServiceImpl::generateProposal() {
      std::vector<model::Transaction> txs;

      while (queue_.empty()) {
        std::this_thread::sleep_for(std::chrono::seconds(delay_seconds_));
      }

      for (model::Transaction tx;
           txs.size() < max_size_ && queue_.try_pop(tx);) {
        txs.push_back(tx);
      }

      proposals_.get_subscriber().on_next(model::Proposal(txs));
    }
  }
}