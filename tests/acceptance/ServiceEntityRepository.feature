Feature: ServiceEntityRepository
  In order to use simplified repository safely
  As a Psalm user
  I need Psalm to typecheck ServiceEntityRepository

  Background:
    Given I have the following config
      """
      <?xml version="1.0"?>
      <psalm totallyTyped="true">
        <projectFiles>
          <directory name="."/>
        </projectFiles>
        <plugins>
          <pluginClass class="Weirdan\DoctrinePsalmPlugin\Plugin" />
        </plugins>
      </psalm>
      """
    And I have the following code preamble
      """
      <?php
      use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
      """

    @ServiceEntityRepository::inheritance
    Scenario: Extending a ServiceEntityRepository
      Given I have the "doctrine/persistence" package satisfying the "< 1.3"
      And I have the following code
        """
        use Doctrine\Common\Persistence\ManagerRegistry as RegistryInterface;

        interface I {}
        /**
         * @method I|null find($id, $lockMode = null, $lockVersion = null)
         * @method I|null findOneBy(array $criteria, array $orderBy = null)
         * @method list<I>    findAll()
         * @method list<I>    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
         * @psalm-suppress PropertyNotSetInConstructor
         */
        class IRepository extends ServiceEntityRepository {
          public function __construct(RegistryInterface $registry) {
            parent::__construct($registry, I::class);
          }
        }
        """
      When I run Psalm
      Then I see no errors

    @ServiceEntityRepository::inheritance
      Scenario: Extending a ServiceEntityRepository
      Given I have the "doctrine/persistence" package satisfying the ">= 1.3"
      And I have the following code
        """
        use Doctrine\Persistence\ManagerRegistry as RegistryInterface;

        interface I {}
        /**
         * @method I|null find($id, $lockMode = null, $lockVersion = null)
         * @method I|null findOneBy(array $criteria, array $orderBy = null)
         * @method list<I>    findAll()
         * @method list<I>    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
         * @psalm-suppress PropertyNotSetInConstructor
         */
        class IRepository extends ServiceEntityRepository {
          public function __construct(RegistryInterface $registry) {
            parent::__construct($registry, I::class);
          }
        }
        """
      When I run Psalm
      Then I see no errors

    @ServiceEntityRepository::generics
      Scenario: Check template notation on ServiceEntityRepository
      Given I have the "doctrine/persistence" package satisfying the "< 1.3"
      And I have the following code
        """
        use Doctrine\Common\Persistence\ManagerRegistry as RegistryInterface;

        interface I {}

        /** @var RegistryInterface $registry */
        $repository = new ServiceEntityRepository($registry, I::class);

        /**
         * @param ServiceEntityRepository<I> $argument
         * @return void
         */
        function assertTemplate($argument) {}
        assertTemplate($repository);
        """
      When I run Psalm
      Then I see no errors

    @ServiceEntityRepository::generics
      Scenario: Check template notation on ServiceEntityRepository
      Given I have the "doctrine/persistence" package satisfying the ">= 1.3"
      And I have the following code
        """
        use Doctrine\Persistence\ManagerRegistry as RegistryInterface;

        interface I {}

        /** @var RegistryInterface $registry */
        $repository = new ServiceEntityRepository($registry, I::class);

        /**
         * @param ServiceEntityRepository<I> $argument
         * @return void
        */
        function assertTemplate($argument) {}
        assertTemplate($repository);
        """
      When I run Psalm
      Then I see no errors
