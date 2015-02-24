require 'octopodes/repositories/thing'
require 'octopodes/domain/creative_work'

module Octopodes
  module Repositories
    # Repository to access CreativeWorks
    class CreativeWork < Thing
      def self.domain
        Domain::CreativeWork
      end

      def self.find_with_parts(uuid)
        dataset = find(uuid)

        if dataset.count > 0
          parts = dataset.first.has_part
          dataset.concat(parts) if parts

          examples = dataset.first.work_example
          dataset.concat(examples) if examples
        end

        dataset
      end

      def self.update_provenance(uuid, data = {}, user = nil)
        model = find(uuid).first

        if data['is_part_of'] && uuid_valid?(data['is_part_of'])
          part_uuid = data['is_part_of']
          part_of = Domain::CreativeWork.where(uuid: part_uuid).first
          model.is_part_of = part_of if part_of
        else
          model.is_part_of = nil
        end

        if data['example_of_work'] && uuid_valid?(data['example_of_work'])
          ex_uuid = data['example_of_work']
          example_of = Domain::CreativeWork.where(uuid: ex_uuid).first
          model.example_of_work = example_of if example_of
        else
          model.example_of_work = nil
        end

        model.updated_by = user if user.is_a?(Domain::User)
        model.save
      end

      # For all, limit dataset to just this type
      def self.all(options = {})
        limit = options[:limit]
        where = options[:where]
        order = options[:order]
        dataset = domain.where(where).where(type: domain.type).order(order)
                  .limit(limit)
        dataset.all
      end

      def self.uuid_valid?(uuid)
        (uuid =~ /^([a-f\d]{8}(-[a-f\d]{4}){3}-[a-f\d]{12}?)$/i) == 0
      end
    end
  end
end
